import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { createInterface } from "node:readline";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type RateLimitWindow = {
  usedPercent: number;
  resetsAt: number | null;
};

type RateLimits = {
  primary: RateLimitWindow | null;
  secondary: RateLimitWindow | null;
};

type PendingRequest = {
  resolve: (result: unknown) => void;
  reject: (error: Error) => void;
  timeout: ReturnType<typeof setTimeout>;
};

const CHATGPT_PROVIDER = "openai-codex";
const REFRESH_INTERVAL_MS = 60_000;
const REQUEST_TIMEOUT_MS = 15_000;
const MAX_RETRY_DELAY_MS = 15 * 60_000;

class CodexAppServer {
  private process: ChildProcessWithoutNullStreams | undefined;
  private pending = new Map<number, PendingRequest>();
  private nextRequestId = 1;
  private starting: Promise<void> | undefined;

  async getRateLimits(): Promise<RateLimits> {
    await this.start();
    const result = (await this.request("account/rateLimits/read", {
      excludeResetCreditDetails: true,
    })) as { rateLimits?: RateLimits };
    return result.rateLimits ?? { primary: null, secondary: null };
  }

  stop(): void {
    this.process?.kill();
    this.process = undefined;
    this.starting = undefined;
    this.rejectPending(new Error("Codex app-server stopped"));
  }

  private async start(): Promise<void> {
    if (this.process && !this.process.killed) return;
    if (this.starting) return this.starting;

    this.starting = new Promise<void>((resolve, reject) => {
      const process = spawn("codex", ["app-server", "--stdio"], { stdio: "pipe" });
      const output = createInterface({ input: process.stdout });
      let initialized = false;

      process.once("error", reject);
      process.once("exit", () => {
        if (this.process === process) this.process = undefined;
        this.rejectPending(new Error("Codex app-server exited"));
        if (!initialized) reject(new Error("Codex app-server exited before initialization"));
      });
      output.on("line", (line) => this.handleMessage(line));

      this.process = process;
      this.request("initialize", {
        clientInfo: { name: "pi-codex-usage", title: null, version: "0.1.0" },
        capabilities: null,
      })
        .then(() => {
          initialized = true;
          resolve();
        })
        .catch(reject);
    }).finally(() => {
      this.starting = undefined;
    });

    return this.starting;
  }

  private request(method: string, params: unknown): Promise<unknown> {
    const process = this.process;
    if (!process || process.killed) return Promise.reject(new Error("Codex app-server is unavailable"));

    const id = this.nextRequestId++;
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`Codex app-server timed out while calling ${method}`));
      }, REQUEST_TIMEOUT_MS);
      this.pending.set(id, { resolve, reject, timeout });
      process.stdin.write(`${JSON.stringify({ id, method, params })}\n`);
    });
  }

  private handleMessage(line: string): void {
    let message: { id?: number; result?: unknown; error?: { message?: string } };
    try {
      message = JSON.parse(line);
    } catch {
      return;
    }
    if (typeof message.id !== "number") return;

    const pending = this.pending.get(message.id);
    if (!pending) return;
    clearTimeout(pending.timeout);
    this.pending.delete(message.id);
    if (message.error) {
      pending.reject(new Error(message.error.message ?? "Codex app-server request failed"));
      return;
    }
    pending.resolve(message.result);
  }

  private rejectPending(error: Error): void {
    for (const pending of this.pending.values()) {
      clearTimeout(pending.timeout);
      pending.reject(error);
    }
    this.pending.clear();
  }
}

function formatResetTime(resetsAt: number | null): string {
  if (!resetsAt) return "?";

  const remainingMinutes = Math.max(0, Math.ceil((resetsAt * 1_000 - Date.now()) / 60_000));
  const days = Math.floor(remainingMinutes / (24 * 60));
  const hours = Math.floor(remainingMinutes % (24 * 60) / 60);
  const minutes = remainingMinutes % 60;
  if (days) return `${days}d${hours}h`;
  if (hours) return `${hours}h${minutes}m`;
  return `${minutes}m`;
}

function formatWindow(label: string, window: RateLimitWindow | null): string {
  if (!window) return `${label} ⠁⠁⠁⠁⠁⠁ ? / ?`;
  const filled = Math.min(6, Math.max(0, Math.ceil(window.usedPercent / (100 / 6))));
  const progress = `${"⣿".repeat(filled)}${"⠁".repeat(6 - filled)}`;
  return `${label} ${progress} ${window.usedPercent.toFixed(0)}% / ${formatResetTime(window.resetsAt)}`;
}

function formatRateLimits(rateLimits: RateLimits): string {
  return `${formatWindow("𝖍", rateLimits.primary)} ${formatWindow("𝖜", rateLimits.secondary)}`;
}

export default function (pi: ExtensionAPI) {
  const appServer = new CodexAppServer();
  let activeProvider: string | undefined;
  let refreshTimer: ReturnType<typeof setInterval> | undefined;
  let nextRefreshAt = 0;
  let retryDelayMs = REFRESH_INTERVAL_MS;
  let context: ExtensionContext | undefined;

  const refresh = async () => {
    if (activeProvider !== CHATGPT_PROVIDER || !context || Date.now() < nextRefreshAt) return;

    try {
      const rateLimits = await appServer.getRateLimits();
      context.ui.setStatus("codex-usage", formatRateLimits(rateLimits));
      retryDelayMs = REFRESH_INTERVAL_MS;
      nextRefreshAt = Date.now() + REFRESH_INTERVAL_MS;
    } catch {
      nextRefreshAt = Date.now() + retryDelayMs;
      retryDelayMs = Math.min(retryDelayMs * 2, MAX_RETRY_DELAY_MS);
    }
  };

  const stopRefreshing = () => {
    if (refreshTimer) clearInterval(refreshTimer);
    refreshTimer = undefined;
    nextRefreshAt = 0;
    context?.ui.setStatus("codex-usage", undefined);
    appServer.stop();
  };

  const startRefreshing = () => {
    if (refreshTimer) return;
    void refresh();
    refreshTimer = setInterval(() => void refresh(), REFRESH_INTERVAL_MS);
  };

  pi.on("session_start", async (_event, ctx) => {
    context = ctx;
    activeProvider = ctx.model?.provider;
    if (activeProvider === CHATGPT_PROVIDER) startRefreshing();
  });

  pi.on("model_select", async (event, ctx) => {
    context = ctx;
    activeProvider = event.model.provider;
    if (activeProvider === CHATGPT_PROVIDER) startRefreshing();
    else stopRefreshing();
  });

  pi.on("session_shutdown", async () => {
    stopRefreshing();
  });
}

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Totals = {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
};

const thinkingLabels: Record<string, string> = {
  off: "𝖔",
  minimal: "𝖒ⁱ",
  low: "𝖑",
  medium: "𝖒",
  high: "𝖍",
  xhigh: "𝖝",
  max: "𝖒⁺",
};

function formatTokens(value: number): string {
  if (value < 1_000) return `${value}`;
  if (value < 1_000_000) return `${(value / 1_000).toFixed(1).replace(/\.0$/, "")}k`;
  return `${(value / 1_000_000).toFixed(1).replace(/\.0$/, "")}m`;
}

function getTotals(ctx: ExtensionContext): Totals & { cacheHitRate?: number } {
  const totals: Totals & { cacheHitRate?: number } = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
  for (const entry of ctx.sessionManager.getBranch() as Array<any>) {
    const usage = entry.type === "message" ? entry.message.usage : entry.usage;
    if (!usage) continue;
    totals.input += usage.input || 0;
    totals.output += usage.output || 0;
    totals.cacheRead += usage.cacheRead || 0;
    totals.cacheWrite += usage.cacheWrite || 0;
    totals.cost += usage.cost?.total || 0;
    if (entry.type === "message" && entry.message.role === "assistant") {
      const promptTokens = usage.input + usage.cacheRead + usage.cacheWrite;
      totals.cacheHitRate = promptTokens ? usage.cacheRead / promptTokens * 100 : undefined;
    }
  }
  return totals;
}

function displayCwd(ctx: ExtensionContext, branch: string | null): string {
  const home = process.env.HOME || process.env.USERPROFILE || "";
  let cwd = ctx.sessionManager.getCwd();
  if (home && cwd.startsWith(home)) cwd = `~${cwd.slice(home.length)}`;
  return branch ? `${cwd} (${branch})` : cwd;
}

export default function (pi: ExtensionAPI) {
  let requestRender = () => {};

  const refresh = () => requestRender();
  pi.on("message_update", refresh);
  pi.on("message_end", refresh);
  pi.on("agent_end", refresh);
  pi.on("model_select", refresh);
  pi.on("thinking_level_select", refresh);

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      requestRender = () => tui.requestRender();
      const unsubscribe = footerData.onBranchChange(requestRender);

      return {
        dispose() {
          unsubscribe();
          requestRender = () => {};
        },
        invalidate() {},
        render(width: number): string[] {
          const totals = getTotals(ctx);
          const context = ctx.getContextUsage();
          const contextWindow = context?.contextWindow || ctx.model?.contextWindow || 0;
          const percent = context?.percent;
          const contextText = percent === null || percent === undefined
            ? `?/${formatTokens(contextWindow)}`
            : `${percent.toFixed(1)}%/${formatTokens(contextWindow)}`;
          const progressColors = ["accent", "accent", "mdLink", "mdLink", "syntaxPunctuation", "syntaxPunctuation"];
          const filled = percent === null || percent === undefined ? 0 : Math.floor(percent / 100 * progressColors.length);
          const progress = progressColors.map((color, index) => {
            return theme.fg(index < filled ? color : "dim", index < filled ? "⣿" : "⠁");
          }).join("");
          const contextLabelColor = filled ? progressColors[Math.min(filled, progressColors.length) - 1] : "dim";
          const stats: string[] = [];
          if (totals.input) stats.push(theme.fg("accent", "↑") + theme.fg("mdCode", formatTokens(totals.input)));
          if (totals.output) stats.push(theme.fg("accent", "↓") + theme.fg("mdCode", formatTokens(totals.output)));
          if (totals.cacheRead) stats.push(theme.fg("accent", "R") + theme.fg("mdCode", formatTokens(totals.cacheRead)));
          if (totals.cacheWrite) stats.push(theme.fg("syntaxPunctuation", "W") + theme.fg("mdCode", formatTokens(totals.cacheWrite)));
          if (totals.cacheHitRate !== undefined) {
            stats.push(theme.fg("syntaxPunctuation", "CH") + theme.fg("mdCode", `${totals.cacheHitRate.toFixed(1)}%`));
          }
          if (totals.cost) stats.push(theme.fg("syntaxPunctuation", "$") + theme.fg("mdCode", totals.cost.toFixed(3)));
          stats.push(progress + " " + theme.fg(contextLabelColor, contextText));
          const model = ctx.model;
          const provider = model && footerData.getAvailableProviderCount() > 1
            ? theme.fg("dim", `(${model.provider}) `)
            : "";
          const modelName = theme.bold(theme.fg("mdCode", model?.id || "no-model"));
          const level = ctx.thinkingLevel || "off";
          const thinkingColor = {
            off: "muted", minimal: "thinkingMinimal", low: "thinkingLow", medium: "thinkingMedium",
            high: "thinkingHigh", xhigh: "thinkingXhigh", max: "thinkingMax",
          }[level] || "muted";
          const thinking = model?.reasoning
            ? theme.fg("muted", " • ") + theme.fg(thinkingColor, thinkingLabels[level] || "𝖔")
            : "";
          const right = provider + modelName + thinking;
          const left = stats.join(theme.fg("muted", " "));
          const padding = " ".repeat(Math.max(2, width - visibleWidth(left) - visibleWidth(right)));
          const branch = footerData.getGitBranch();
          const lines = [theme.fg("dim", displayCwd(ctx, branch)), left + padding + right];
          for (const text of footerData.getExtensionStatuses().values()) {
            lines.push(theme.fg("dim", text));
          }
          return lines.map((line) => truncateToWidth(line, width));
        },
      };
    });
  });
}

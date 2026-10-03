import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import { mixColors, type EditorTheme, type TUI } from "@earendil-works/pi-tui";

const LOGO_WIDTH = 6;
const ANIMATION_FRAME_MS = 50;
const ANIMATION_CYCLE_MS = 1_800;

/**
 * Render the Pi logo beside the chat editor
 */
class PiLogoEditor extends CustomEditor {
  private readonly colorSections: (brightness: number[]) => string[];
  private animationStartedAt = 0;
  private animationTimer: ReturnType<typeof setInterval> | undefined;

  /**
   * Create an editor with an animated honey Pi logo
   *
   * @param tui - the active terminal UI
   * @param theme - the editor theme
   * @param keybindings - the Pi keybindings
   * @param colorSections - render the logo sections with their brightness
   * @return - the editor instance
   */
  constructor(
    tui: TUI,
    theme: EditorTheme,
    keybindings: KeybindingsManager,
    colorSections: (brightness: number[]) => string[],
  ) {
    super(tui, theme, keybindings);
    this.colorSections = colorSections;
  }

  /**
   * Start or stop the working animation
   *
   * @param isWorking - whether Pi is processing an agent turn
   * @return - nothing
   */
  setWorking(isWorking: boolean): void {
    if (isWorking === Boolean(this.animationTimer)) return;

    if (!isWorking) {
      clearInterval(this.animationTimer);
      this.animationTimer = undefined;
      this.invalidate();
      this.tui.requestRender();
      return;
    }

    this.animationStartedAt = performance.now();
    this.animationTimer = setInterval(() => {
      this.invalidate();
      this.tui.requestRender();
    }, ANIMATION_FRAME_MS);
    this.animationTimer.unref?.();
  }

  /**
   * Render the editor with the honey Pi logo on its left
   *
   * @param width - the available editor width
   * @return - the editor lines with the logo prefix
   */
  override render(width: number): string[] {
    if (width <= LOGO_WIDTH) return super.render(width);

    const editorLines = super.render(width - LOGO_WIDTH);
    const logoLines = this.colorSections(this.getSectionBrightness());

    return editorLines.map((line, index) => (logoLines[index] ?? " ".repeat(LOGO_WIDTH)) + line);
  }

  /**
   * Get a smooth brightness wave for each logo section
   *
   * @return - the brightness of the top, lower-left and lower-right sections
   */
  private getSectionBrightness(): number[] {
    if (!this.animationTimer) return [];

    const elapsed = performance.now() - this.animationStartedAt;
    const phase = elapsed / ANIMATION_CYCLE_MS * Math.PI * 2;
    return [0, 1, 2].map((section) => 0.3 + 0.7 * (Math.cos(phase - section * Math.PI * 2 / 3) + 1) / 2);
  }
}

/**
 * Register the honey Pi logo editor
 *
 * @param pi - the Pi extension API
 * @return - nothing
 */
export default function piLogoExtension(pi: ExtensionAPI): void {
  let editor: PiLogoEditor | undefined;

  pi.on("agent_start", () => editor?.setWorking(true));
  pi.on("agent_end", () => editor?.setWorking(false));
  pi.on("session_shutdown", () => editor?.setWorking(false));

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      editor = new PiLogoEditor(tui, theme, keybindings, (brightness) => {
        if (brightness.length === 0) {
          return [ctx.ui.theme.fg("accent", " █▀█") + "  ", ctx.ui.theme.fg("accent", " █▀ █") + " "];
        }

        const color = (text: string, index: number) => {
          return ctx.ui.theme.style(text, {
            fg: mixColors(ctx.ui.theme.colors.dim, ctx.ui.theme.colors.accent, brightness[index]!),
          });
        };
        return [" " + color("█▀█", 0) + "  ", " " + color("█▀", 1) + " " + color("█", 2) + " "];
      });
      return editor;
    });
  });
}

import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";

const LOGO_WIDTH = 6;

/**
 * Render the Pi logo beside the chat editor
 */
class PiLogoEditor extends CustomEditor {
  private readonly colorLogo: (line: string) => string;

  /**
   * Create an editor with a honey Pi logo
   *
   * @param tui - the active terminal UI
   * @param theme - the editor theme
   * @param keybindings - the Pi keybindings
   * @param colorLogo - color a logo line with the current theme
   * @return - the editor instance
   */
  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager, colorLogo: (line: string) => string) {
    super(tui, theme, keybindings);
    this.colorLogo = colorLogo;
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
    const logoLines = [this.colorLogo(" █▀█") + "  ", this.colorLogo(" █▀ █") + " "];

    return editorLines.map((line, index) => (logoLines[index] ?? " ".repeat(LOGO_WIDTH)) + line);
  }
}

/**
 * Register the honey Pi logo editor
 *
 * @param pi - the Pi extension API
 * @return - nothing
 */
export default function piLogoExtension(pi: ExtensionAPI): void {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      return new PiLogoEditor(tui, theme, keybindings, (line) => ctx.ui.theme.fg("accent", line));
    });
  });
}

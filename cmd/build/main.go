package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strings"
)

type Palette struct {
	Name   string            `json:"name"`
	Colors map[string]string `json:"colors"`
}

func main() {
	_, source, _, ok := runtime.Caller(0)
	if !ok {
		fail(fmt.Errorf("cannot find build source"))
	}
	root := filepath.Clean(filepath.Join(filepath.Dir(source), "../.."))

	data, err := os.ReadFile(filepath.Join(root, "shared/palette.json"))
	if err != nil {
		fail(err)
	}
	var palette Palette
	if err := json.Unmarshal(data, &palette); err != nil {
		fail(err)
	}

	files := map[string]string{
		"neovim/lua/miel/palette.lua":         luaPalette(palette.Colors),
		"pi/themes/miel.json":                 piTheme(palette),
		"oh-my-posh/themes/miel.omp.json":     ohMyPoshTheme(palette.Colors),
		"oh-my-posh/scripts/miel-versions.sh": ohMyPoshVersions(),
		"tmux/miel.conf":                      tmuxTheme(palette.Colors),
	}
	check := len(os.Args) == 2 && os.Args[1] == "--check"
	for path, content := range files {
		path = filepath.Join(root, path)
		if check {
			actual, err := os.ReadFile(path)
			if err != nil || string(actual) != content {
				fmt.Printf("out of date: %s\n", strings.TrimPrefix(path, root+string(os.PathSeparator)))
				os.Exit(1)
			}
			continue
		}
		mode := os.FileMode(0644)
		if strings.HasPrefix(filepath.Base(path), "miel-") {
			mode = 0755
		}
		if err := os.WriteFile(path, []byte(content), mode); err != nil {
			fail(err)
		}
		if err := os.Chmod(path, mode); err != nil {
			fail(err)
		}
	}
}

func fail(err error) {
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}

func luaPalette(colors map[string]string) string {
	keys := []string{"bg", "crust", "mantle", "surface", "muted", "dim", "blue", "blue_strong", "text", "cream", "dim_gold", "muted_gold", "gold", "hot_gold", "bronze", "success", "warning", "error", "selected", "success_bg", "error_bg"}
	var out strings.Builder
	out.WriteString("return {\n")
	for _, key := range keys {
		fmt.Fprintf(&out, "  %s = %q,\n", key, colors[key])
	}
	out.WriteString("}\n")
	return out.String()
}

func piTheme(palette Palette) string {
	colors := map[string]string{
		"accent": "gold", "border": "blue", "borderAccent": "hot_gold", "borderMuted": "muted",
		"success": "success", "error": "error", "warning": "warning", "muted": "muted", "dim": "dim",
		"text": "text", "thinkingText": "dim", "selectedBg": "selected", "scrollbarTrack": "muted",
		"scrollbarThumb": "gold", "searchMatchBg": "hot_gold", "searchMatchText": "crust",
		"userMessageBg": "mantle", "userMessageText": "cream", "customMessageBg": "surface",
		"customMessageText": "text", "customMessageLabel": "hot_gold", "toolPendingBg": "mantle",
		"toolSuccessBg": "success_bg", "toolErrorBg": "error_bg", "toolTitle": "cream", "toolOutput": "text",
		"mdHeading": "gold", "mdLink": "hot_gold", "mdLinkUrl": "dim_gold", "mdCode": "cream",
		"mdCodeBlock": "success", "mdCodeBlockBorder": "dim_gold", "mdQuote": "text",
		"mdQuoteBorder": "muted", "mdHr": "dim_gold", "mdListBullet": "gold",
		"toolDiffAdded": "success", "toolDiffRemoved": "error", "toolDiffContext": "dim",
		"syntaxComment": "muted", "syntaxKeyword": "blue", "syntaxFunction": "cream",
		"syntaxVariable": "text", "syntaxString": "success", "syntaxNumber": "warning",
		"syntaxType": "success", "syntaxOperator": "text", "syntaxPunctuation": "muted_gold",
		"thinkingOff": "muted", "thinkingMinimal": "dim", "thinkingLow": "success",
		"thinkingMedium": "gold", "thinkingHigh": "warning", "thinkingXhigh": "error",
		"thinkingMax": "error", "bashMode": "hot_gold",
	}
	theme := map[string]any{
		"$schema": "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json",
		"name":    palette.Name, "vars": palette.Colors, "colors": colors,
		"export": map[string]string{"pageBg": palette.Colors["bg"], "cardBg": palette.Colors["mantle"], "infoBg": palette.Colors["surface"]},
	}
	data, err := json.MarshalIndent(theme, "", "  ")
	if err != nil {
		fail(err)
	}
	return string(data) + "\n"
}

func versionCommandSegments() string {
	const versionSlots = 10
	colors := []string{"#d70000", "#ff5f00", "#ffaf00", "#e5a717"}
	var segments strings.Builder
	for index := 0; index < versionSlots; index++ {
		template, err := json.Marshal(fmt.Sprintf(`{{ cmd "sh" "-c" "miel-versions %d" }}`, index))
		if err != nil {
			fail(err)
		}
		fmt.Fprintf(&segments, `        {
          "type": "text",
          "style": "plain",
          "foreground": "light-gradient(%s)",
          "template": %s
        },
`, colors[index%len(colors)], template)
	}
	return segments.String()
}

func shortenedPathTemplate() string {
	template := `{{ $folders := splitList "/" .Location }}` +
		`{{ $lastFullFolder := sub (len $folders) 2 }}` +
		`{{ range $index, $folder := $folders }}{{ if ne $folder "" }}/` +
		`{{ if lt $index $lastFullFolder }}{{ if hasPrefix "." $folder }}` +
		`{{ substr 0 2 $folder }}{{ else }}{{ substr 0 1 $folder }}{{ end }}` +
		`{{ else }}{{ $folder }}{{ end }}{{ end }}{{ end }} `
	encoded, err := json.Marshal(template)
	if err != nil {
		fail(err)
	}
	return string(encoded)
}

func ohMyPoshVersions() string {
	return `#!/bin/sh
# Generated by cmd/build. Edit shared/palette.json instead.

active_index=0
requested_index=${1-}
# Preserve spacing between text segments.
separator='⁠ '
selected() { [ "$requested_index" = "$active_index" ]; }
skip() { active_index=$((active_index + 1)); }
clean_version() {
  printf '%s' "$1" | sed -E 's/^(v|Version[[:space:]]+|go|Python[[:space:]]+)//'
}
add() {
  display_version=$(clean_version "$2")
  [ "$active_index" -eq 0 ] || printf '%s' "$separator"
  printf '%s %s' "$1" "$display_version"
  active_index=$((active_index + 1))
}
version() { "$@" 2>/dev/null || printf 'nover'; }
go_version() {
  command -v go >/dev/null 2>&1 && go version 2>/dev/null | awk '{print $3}' || printf 'nover'
}
java_version() {
  command -v java >/dev/null 2>&1 && java -version 2>&1 | awk -F '"' '/version/ { print $2; exit }' || printf 'nover'
}
python_version() {
  command -v python3 >/dev/null 2>&1 && version python3 --version || version python --version
}
qml_version() {
  if command -v qml >/dev/null 2>&1; then
    qml --version 2>&1 | awk 'NR == 1 { print $NF; exit }'
  elif command -v qmake >/dev/null 2>&1; then
    qmake -query QT_VERSION 2>/dev/null
  else
    printf 'nover'
  fi
}

if [ -f package.json ]; then
  selected && add '' "$(version node --version)" || skip
fi
if [ -f tsconfig.json ]; then
  selected && add '' "$(version tsc --version)" || skip
fi
if [ -f go.mod ]; then
  selected && add '' "$(go_version)" || skip
fi
if [ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then
  selected && add '' "$(java_version)" || skip
fi
if [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f Pipfile ] || [ -f setup.py ]; then
  selected && add '' "$(python_version)" || skip
fi
if [ -f .qmlproject ] || [ -f ./*.qml ]; then
  selected && add 'QML' "$(qml_version)" || skip
fi

dir=$PWD
  root=
  while :; do
    if [ -f "$dir/package.json" ]; then
    root=$dir
      break
    fi
    [ "$dir" = / ] && break
    dir=${dir%%/*}
    [ -n "$dir" ] || dir=/
  done
if [ -n "$root" ] && { [ -f "$root/turbo.json" ] || [ -f "$root/turbo.jsonc" ]; }; then
  if selected; then
    turbo_version=
    if [ -x "$root/node_modules/.bin/turbo" ]; then
      turbo_version=$("$root/node_modules/.bin/turbo" --version 2>/dev/null | head -n 1)
    elif command -v turbo >/dev/null 2>&1; then
      turbo_version=$(turbo --version 2>/dev/null | head -n 1)
    elif command -v node >/dev/null 2>&1; then
      turbo_version=$(node -e 'const p=require(process.argv[1]); console.log((p.devDependencies||{}).turbo||(p.dependencies||{}).turbo||"")' "$root/package.json" 2>/dev/null)
    fi
    [ -n "$turbo_version" ] && add '' "$turbo_version"
  else
    skip
  fi
fi
if [ -f yarn.lock ]; then
  selected && add '' "$(version yarn --version)" || skip
fi
if [ -f package-lock.json ]; then
  selected && add '' "$(version npm --version)" || skip
fi
if [ -f pnpm-lock.yaml ]; then
  selected && add '' "$(version pnpm --version)" || skip
fi
exit 0
`
}

func ohMyPoshTheme(c map[string]string) string {
	return fmt.Sprintf(`{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 4,
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "root",
          "style": "plain",
          "foreground": %q,
          "template": "root <%s>in</> "
        },
        {
          "type": "path",
          "style": "plain",
          "foreground": %q,
          "template": %s,
          "options": {
            "style": "full"
          }
        },
        {
          "type": "git",
          "style": "plain",
          "foreground": %q,
          "template": "<%s>on</> {{ if .IsWorkTree }}󰉍 {{ end }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Rebase }} 󰑓{{ end }}{{ if .Merge }} 󰘬{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }} ",
          "options": {
            "branch_icon": " ",
            "fetch_status": true
          }
        },
%s
        {
          "type": "status",
          "style": "plain",
          "foreground": %q,
          "template": "⁠ x "
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "foreground": %q,
          "template": "λ "
        }
      ]
    }
  ]
}
`, c["bronze"], c["cream"], c["gold"], shortenedPathTemplate(), c["hot_gold"], c["cream"],
		versionCommandSegments(), c["bronze"], c["hot_gold"])
}

func tmuxTheme(c map[string]string) string {
	letters := []rune("𝖆𝖇𝖈𝖉𝖊𝖋𝖌𝖍𝖎𝖏𝖐𝖑𝖒𝖓𝖔𝖕𝖖𝖗𝖘𝖙𝖚𝖛𝖜𝖝𝖞𝖟")
	label := "#I"
	for index := len(letters) - 1; index >= 0; index-- {
		label = fmt.Sprintf("#{?#{==:#I,%d},%c,%s}", index+1, letters[index], label)
	}
	return fmt.Sprintf(`# Generated by cmd/build. Edit shared/palette.json instead.
set -g @miel-bg %q
set -g @miel-text %q
set -g @miel-dim %q
set -g @miel-gold %q
set -g @miel-gold-hot %q
set -g @miel-cream %q
set -g @miel-good %q
set -g @miel-warn %q
set -g @miel-critical %q
set -g @miel-surface %q

set -g status on
set -g status-interval 1
set -g status-justify left
set -g status-style "bg=#{@miel-bg},fg=#{@miel-text}"
set -g status-left-length 100
set -g status-right-length 100
set -g status-left "#[fg=#{@miel-gold},bg=#{@miel-bg},bold] #S #[fg=#{@miel-dim},bg=#{@miel-bg}]/ "
set -g window-status-separator ""
set -g @miel-window-label %q
setw -g window-status-format "#[fg=#{@miel-dim},bg=#{@miel-bg}]│#[fg=#{@miel-text},bg=#{@miel-bg}] #{E:@miel-window-label} #W "
setw -g window-status-current-format "#[fg=#{@miel-gold},bg=#{@miel-surface}]│> #[bold]#{E:@miel-window-label} #W #[nobold]<#[fg=#{@miel-dim},bg=#{@miel-bg}]"
set -g status-right "#[fg=#{@miel-dim},bg=#{@miel-bg}]⛬ #[fg=#{@miel-gold-hot},bg=#{@miel-bg},bold]#h #[fg=#{@miel-dim},bg=#{@miel-bg}]| #[fg=#{@miel-cream},bg=#{@miel-bg},bold]%%H:%%M#[fg=#{@miel-dim},bg=#{@miel-bg}] ⠶ #[fg=#{@miel-text},bg=#{@miel-bg}]%%d-%%b "
set -g pane-border-style "fg=#{@miel-dim}"
set -g pane-active-border-style "fg=#{@miel-gold}"
set -g message-style "bg=#{@miel-gold},fg=#{@miel-bg},bold"
set -g mode-style "bg=#{@miel-gold-hot},fg=#{@miel-bg},bold"
`, c["bg"], c["text"], c["dim_gold"], c["gold"], c["hot_gold"], c["cream"], c["success"], c["warning"], c["error"], c["surface"], label)
}

# Miel

A honey-gold theme for Neovim, Pi, and tmux.

Edit `palette.json`, then run `go run ./cmd/build`. Do not edit generated files.

## Install

### Neovim

```lua
{ "your-user/miel", lazy = false, priority = 900 }
```

Miel provides the shared lualine palette. It does not replace your colorscheme.
For a local checkout, use `dir = "~/Documents/miel"` instead.

### Pi

```sh
pi install git:github.com/your-user/miel
```

The package installs the Miel theme and footer extension. Select `miel` in `/settings`.
For local development, run `pi install ~/Documents/miel`.

The footer uses gold token labels, cream values, semantic context colors, and Fraktur thinking levels.

### tmux

With TPM:

```tmux
set -g @plugin 'your-user/miel'
```

Or source a local checkout:

```tmux
source-file ~/Documents/miel/miel.tmux
```

Window labels are Fraktur `𝖆` through `𝖟`. Higher indexes use their number.

## Develop

```sh
go run ./cmd/build
go run ./cmd/build --check
```

`--check` fails when generated files are stale.

# 🍯 Miel

A honey-gold theme for Neovim, Pi, Tmux and Oh my posh.

Work well with [oasis moonlight](https://github.com/uhs-robert/oasis.nvim) (included as dependencies for nvim).

## Features and screenshot

- [Neovim miel](docs/neovim.md): Oasis Moonlight highlights, lualine theme, borders, and Alpha dashboard.
- [Pi miel](docs/pi.md): Miel theme and status footer.
- [Oh My Posh](docs/oh-my-posh.md): shell prompt with Miel colors, Git, worktree and stash status.
- [tmux miel](docs/tmux.md): status bar, pane borders, and window labels.

### Nvim

#### Editor

<img width="2539" height="1347" alt="image" src="https://github.com/user-attachments/assets/542f5006-15f6-4d2d-a770-85a3cdd29e85" />

#### Alpha dash after few minutes

<img width="1919" height="1054" alt="flake" src="https://github.com/user-attachments/assets/b2dbe25b-428f-48d6-9c54-c3de06054750" />

### Tmux
<img width="2546" height="1355" alt="image" src="https://github.com/user-attachments/assets/3a5f4cf1-c017-473d-87e3-622173f3a737" />

### Pi 

<img width="2550" height="593" alt="pi" src="https://github.com/user-attachments/assets/a7c9b14c-ed38-47c6-8ce1-dd6b30c11202" />

### Oh my posh

<img width="718" height="261" alt="omp" src="https://github.com/user-attachments/assets/f93b803e-3bcb-41bc-8c49-97fd2b07d6b2" />

## Install

Clone Miel once, then point each integration to this directory:

```sh
git clone https://github.com/bouteillerAlan/miel.git ~/.config/miel
```

### [Neovim](https://neovim.io/)

Use the shared clone as a local plugin:

```lua
{
  dir = vim.fn.expand("~/.config/miel"),
  dependencies = {
    "uhs-robert/oasis.nvim",
    "nvim-lualine/lualine.nvim",
    "goolord/alpha-nvim",
    "nvim-mini/mini.icons",
    "nvim-lua/plenary.nvim",
  },
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/neovim")
    require("miel").setup()
  end,
}
```

Miel configures Oasis Moonlight with Miel highlights, a lualine bar, gold window borders, and an animated Alpha dashboard.

Choose which integrations to enable with `setup`. All are enabled by default:

```lua
require("miel").setup({
  nvim = true,
  lualine = false,
  alpha = false,
})
```

### [Pi](https://pi.dev)

Install the Pi package from the shared clone:

```sh
pi install ~/.config/miel
```

The package installs the Miel theme, footer extension, and Codex quota extension. Select `miel` in `/settings`.

The footer uses custom color and unicode thinking level. The context colors are gradient in function of the %. Codex models show their 5-hour and weekly quota meters with reset times. Only Codex is supported for now. Install the Codex CLI and sign in with the same ChatGPT account to show the quota meters.

### [Oh My Posh](https://ohmyposh.dev)

Link and load Oh My Posh from the shared clone:

```sh
ln -s ~/.config/miel/oh-my-posh/scripts/miel-versions.sh ~/.local/bin/miel-versions

# ~/.zshrc
eval "$(oh-my-posh init zsh --config ~/.config/miel/oh-my-posh/themes/miel.omp.json)"
```

For Bash, replace `zsh` with `bash` and add it to `~/.bashrc`.

### [Tmux](https://github.com/tmux/tmux/wiki)

Add this to `~/.tmux.conf` to load Miel automatically whenever tmux starts:

```tmux
# Load the Miel theme.
source-file ~/.config/miel/tmux/miel.conf
```

Start tmux normally after saving the file. To apply the theme to an existing tmux session, run:

```sh
tmux source-file ~/.tmux.conf
```

Window labels are Fraktur `𝖆` (a) through `𝖟` (z). Higher indexes use their number.

## Develop

```sh
go run ./cmd/build
go run ./cmd/build --check
```

`--check` fails when generated files are stale.

## Code of conduct, license, authors, changelog, contributing

See the following file :
- [code of conduct](CODE_OF_CONDUCT.md)
- [license](LICENSE)
- [authors](AUTHORS)
- [contributing](CONTRIBUTING.md)
- [changelog](CHANGELOG)
- [security](SECURITY.md)

## Want to participate? Have a bug or a request feature?

Do not hesitate to open a pr or an issue. I reply when I can.

## Want to support my work?

- [Give me a tips](https://ko-fi.com/a2n00)
- [Give a star on github](https://github.com/bouteillerAlan/miel)
- Or just participate to the development :D

### Thanks !

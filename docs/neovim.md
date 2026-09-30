# Neovim

Miel configures [Oasis](https://github.com/uhs-robert/oasis.nvim) Moonlight and
[lualine](https://github.com/nvim-lualine/lualine.nvim) with its honey-gold palette.

## Features

- Oasis Moonlight colorscheme with Miel diagnostic and Git sign colors.
- Gold split and floating-window borders.
- Mode-aware lualine badges: gold for normal, green for insert, orange for visual, red for replace, cream for command, and bright gold for terminal mode.
- Statusline Git branch, diff, diagnostics, shortened absolute file path, encoding, line-ending bytes, LSP client or filetype, DAP breakpoints, and a six-step braille scroll indicator with percentage.
- Fraktur mode labels and a compact three-directory path.
- Animated Alpha dashboard with seasonal palettes and falling flakes.

## Install

Clone Miel once:

```sh
git clone https://github.com/bouteillerAlan/miel.git ~/.config/miel
```

Add the shared clone as a local plugin in your `lazy.nvim` specification:

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

`setup()` enables all integrations. Disable any of them when needed:

```lua
require("miel").setup({
  nvim = true,
  lualine = false,
  alpha = false,
})
```

The Alpha dashboard selects a seasonal palette automatically. Override it at startup with one of these commands:

```sh
nvim --cmd 'let g:alpha_xmas = 1'
nvim --cmd 'let g:alpha_halloween = 1'
nvim --cmd 'let g:alpha_st_patricks = 1'
nvim --cmd 'let g:alpha_easter = 1'
```

Use `:AlphaCyclePalette` to switch palettes while the dashboard is open.

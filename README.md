# Miel

A honey-gold theme for Neovim, Pi, and tmux.

Work well with [oasis moonlight](https://github.com/uhs-robert/oasis.nvim)

Nvim
<img width="2539" height="1347" alt="image" src="https://github.com/user-attachments/assets/542f5006-15f6-4d2d-a770-85a3cdd29e85" />

Tmux and pi
<img width="2546" height="1355" alt="image" src="https://github.com/user-attachments/assets/3a5f4cf1-c017-473d-87e3-622173f3a737" />
<img width="2543" height="52" alt="image" src="https://github.com/user-attachments/assets/7fcad75e-7abf-4626-ab8d-97abde8f8f49" />

## Install

### Neovim

```lua
{
  "bouteillerAlan/miel",
  dependencies = {
    "uhs-robert/oasis.nvim",
    "nvim-lualine/lualine.nvim",
  },
  config = function()
    require("miel").setup()
  end,
}
```

Miel configures Oasis Moonlight with Miel highlights and a lualine bar. Its Neovim setup sets gold window and float borders.

Choose either integration with `setup`:

```lua
require("miel").setup({
  nvim = true,
  lualine = false,
})
```

Both are enabled by default. For a local checkout, use `dir = "~/Documents/miel"` instead.

### Pi

```sh
pi install git:github.com/bouteillerAlan/miel
```

The package installs the Miel theme and footer extension. Select `miel` in `/settings`.
For local development, run `pi install ~/Documents/miel`.

The footer uses custom color and unicode thinking level. The context colors are gradient in function of the %.

### tmux

With TPM:

```tmux
set -g @plugin 'bouteillerAlan/miel'
```

Or source a local checkout:

```tmux
source-file ~/Documents/miel/miel.tmux
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

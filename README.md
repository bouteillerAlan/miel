# Miel

A honey-gold theme for Neovim, Pi, and tmux.

Work well with [oasis moonlight](https://github.com/uhs-robert/oasis.nvim)

## Install

### Neovim

```lua
{ "bouteillerAlan/miel" }
```

Miel provides the shared lualine palette. It does not replace your colorscheme.
For a local checkout, use `dir = "~/Documents/miel"` instead.

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

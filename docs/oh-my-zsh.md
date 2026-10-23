# Oh My Zsh

Miel includes a native Oh My Zsh theme at `oh-my-zsh/themes/miel.zsh-theme`.
It provides the same prompt layout and version indicators as the Oh My Posh theme.

## Features

- Honey-gold prompt based on the Miel palette.
- Root indicator, compact path, Git status, command status, and a second-line `λ` prompt marker.
- Git uses Nerd Font icons for branches (``), worktrees (`󰉍`), stashes (``), rebases (`󰑓`) and merges (`󰘬`).
- Compact paths keep the last two directories complete; earlier directories are reduced to their first letter.
- The `miel-versions` helper shows Node, TypeScript, Go, Java, Python, QML, Turbo, Yarn, npm, and pnpm versions when their project files are present.
- Version entries use the Miel red, orange, amber, and gold colors by position.

## Install

Install [Oh My Zsh](https://ohmyz.sh/) and use a Nerd Font so the Git and language icons render correctly.

Link the theme and version helper from the shared Miel clone:

```sh
ln -s ~/.config/miel/oh-my-zsh/themes/miel.zsh-theme \
  "${ZSH_CUSTOM:-$ZSH/custom}/themes/miel.zsh-theme"
ln -s ~/.config/miel/oh-my-posh/scripts/miel-versions.sh ~/.local/bin/miel-versions
```

Set the theme in `~/.zshrc`:

```sh
ZSH_THEME="miel"
```

The native theme does not require Oh My Posh. Restart the shell after changing `ZSH_THEME`.

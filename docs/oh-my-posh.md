# Oh My Posh

Miel includes `themes/miel.omp.json`, an Oh My Posh prompt using only the Miel palette.

## Included segments

- Root, path, Git, Node, TypeScript, Turbo, Yarn, npm, pnpm, and status segments from `star.omp.json`.
- The original Oh My Posh icons for Git and language segments.
- The `➜` prompt marker.

## Install

Point Oh My Posh to the theme from your shell startup file:

```sh
# ~/.zshrc
eval "$(oh-my-posh init zsh --config ~/Documents/miel/themes/miel.omp.json)"
```

For Bash, replace `zsh` with `bash` and add it to `~/.bashrc`. The theme keeps the original icons, so use a Nerd Font.

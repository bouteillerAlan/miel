# Oh My Posh

Miel includes `themes/miel.omp.json`, an Oh My Posh prompt using only the Miel palette.

## Included segments

- Root, path, Git, Node, TypeScript, Turbo, Yarn, npm, pnpm, and status segments from `star.omp.json`.
- The original Oh My Posh icons for Git and language segments.
- The `➜` prompt marker.

## Install

Add the dynamic version script to your `PATH`, then point Oh My Posh to the theme:

```sh
ln -s ~/Documents/miel/scripts/miel-versions.sh ~/.local/bin/miel-versions

# ~/.zshrc
eval "$(oh-my-posh init zsh --config ~/Documents/miel/themes/miel.omp.json)"
```

For Bash, replace `zsh` with `bash` and add it to `~/.bashrc`. The version script applies the gold gradient and detects Turbo from the nearest project root. The theme keeps the original icons, so use a Nerd Font.

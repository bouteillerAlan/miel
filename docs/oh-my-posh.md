# Oh My Posh

Miel includes `oh-my-posh/themes/miel.omp.json`, an Oh My Posh prompt using only the Miel palette.

## Included segments

- Root, path, Git, Node, TypeScript, Go, Java, Python, QML, Turbo, Yarn, npm, pnpm, and status segments from `star.omp.json`.
- The original Oh My Posh icons for Git and language segments.
- A compact path: parent folders use their first letter, including the dot for hidden folders, while the last two folders remain complete.
- The `λ` prompt marker.

## Install

Clone the repository, or download and extract its files to `~/.config/oh-my-posh/miel`.

```sh
git clone https://github.com/bouteillerAlan/miel.git ~/.config/oh-my-posh/miel
ln -s ~/.config/oh-my-posh/miel/oh-my-posh/scripts/miel-versions.sh ~/.local/bin/miel-versions

# ~/.zshrc
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/miel/oh-my-posh/themes/miel.omp.json)"
```

For Bash, replace `zsh` with `bash` and add it to `~/.bashrc`. The version script applies the gold gradient and detects Turbo from the nearest project root. The theme keeps the original icons, so use a Nerd Font.

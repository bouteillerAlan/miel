# Oh My Posh

Miel includes `oh-my-posh/themes/miel.omp.json` and the `miel-versions` helper script.
It requires Oh My Posh 31.4.0 or later for the version gradient.

## Features

- Honey-gold prompt based on the Miel palette.
- Root indicator, compact path, Git branch and working-tree status, command status, and a second-line `λ` prompt marker.
- Compact paths keep the last two directories complete; earlier directories are reduced to their first letter.
- Project tool versions for Node, TypeScript, Go, Java, Python, QML, Turbo, Yarn, npm, and pnpm when their project files are present.
- Version entries use a five-step gold gradient. Turbo is detected from the nearest `package.json` project root.

## Install

Install [Oh My Posh](https://ohmyposh.dev/docs/installation) and use a Nerd Font so the Git and language icons render correctly.

Then clone Miel and link its helper script:

```sh
git clone https://github.com/bouteillerAlan/miel.git ~/.config/miel
mkdir -p ~/.local/bin
ln -s ~/.config/miel/oh-my-posh/scripts/miel-versions.sh ~/.local/bin/miel-versions
```

Add this to `~/.zshrc`:

```sh
eval "$(oh-my-posh init zsh --config ~/.config/miel/oh-my-posh/themes/miel.omp.json)"
```

For Bash, replace `zsh` with `bash` and add the command to `~/.bashrc`. Restart the shell or source its configuration file.

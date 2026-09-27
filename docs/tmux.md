# tmux

Miel provides a honey-gold tmux status bar and pane styling.

## Features

- Dark status bar with gold session name and active-window accents.
- Fraktur window labels from `𝖆` through `𝖟` for windows 1 through 26; later windows use their numeric index.
- Window names, hostname, 24-hour clock, and date in the status bar.
- Gold active-pane borders and dim inactive-pane borders.
- Gold message styling and bright-gold copy-mode styling.
- One-second status refresh interval and left-aligned window list.

## Install

Clone Miel once:

```sh
git clone https://github.com/bouteillerAlan/miel.git ~/.config/miel
```

Add this line to `~/.tmux.conf`:

```tmux
source-file ~/.config/miel/tmux/miel.conf
```

Reload tmux configuration:

```sh
tmux source-file ~/.tmux.conf
```

Alternatively, source `~/.config/miel/tmux/miel.tmux`; it locates and loads `miel.conf` relative to itself.

# Pi

Miel provides a Pi theme and a TUI footer extension.

## Features

Footer is mostly the default one but packed in an extension to be able to use different color for each section.

- Honey-gold dark theme for interface borders, Markdown, syntax, diffs, tools, selections, messages, search results, and scrollbars.
- Thinking-level colors with Fraktur Unicode indicators for off through max.
- Two-line footer showing the current directory and Git branch.
- Session totals for input, output, cache reads, cache writes, cache-hit rate, and cost.
- Six-step braille context meter, context percentage, and context-window size.
- Selected provider when more than one provider is available, model name, reasoning level, and extension status messages.
- Footer updates as messages, agents, models, thinking levels, and branches change.

## Install

Clone Miel once:

```sh
git clone https://github.com/bouteillerAlan/miel.git ~/.config/miel
```

Install the package from that clone:

```sh
pi install ~/.config/miel
```

Start Pi, open `/settings`, and select the `miel` theme. The package installs both the theme and footer extension; no separate extension configuration is required.

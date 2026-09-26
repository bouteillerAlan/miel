#!/usr/bin/env sh

current_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmux source-file "$current_dir/miel.conf"

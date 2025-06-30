#!/bin/bash

if [[ $# -eq 1 ]]; then
    selected="$1"
else
    dirs=()
    if [[ "$PWD" != "$HOME" ]]; then
        dirs+=("$PWD")
    fi
    dirs+=(
        ~/pdf
        ~/Downloads
    )
    selected=$(
        find ${dirs[@]} -iname "*.pdf" | \
        fzf --preview "pdftotext -f 1 -l 5 {} -" --preview-window=up:50%:wrap
    )
fi

if [[ -z "$selected" ]]; then
    exit 1
fi

selected_name=$(basename "$selected" | tr . _)

tmux new-window -n "$selected_name" -d zathura "$selected"


#!/usr/bin/env bash

# Get all directories in ~/Code
code_dirs=$(find ~/Code -maxdepth 2 -mindepth 2 -type d -not -path "*/\.*" -not -path "~/Code" | sort)

# Use fzf to select a directory
selected_dir=$(echo "$code_dirs" | fzf --height 40% --reverse --prompt="Select project directory: ")

# Exit if no directory was selected
if [[ -z "$selected_dir" ]]; then
    exit 0
fi

# Get the basename of the directory to use as session name
session_name=$(basename "$selected_dir")

# Check if a tmux session with this name already exists
tmux_running=$(pgrep tmux)
if [[ -n "$tmux_running" ]]; then
    # Check if the session exists
    tmux has-session -t="$session_name" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        # Session exists, attach to it
        if [[ -n "$TMUX" ]]; then
            # Already in a tmux session, switch to the other session
            tmux switch-client -t "$session_name"
        else
            # Not in a tmux session, attach to it
            tmux attach-session -t "$session_name"
        fi
        exit 0
    fi
fi

# Create a new session
if [[ -n "$TMUX" ]]; then
    # Already in a tmux session, create a new session and switch to it
    tmux new-session -d -s "$session_name" -c "$selected_dir"
    tmux switch-client -t "$session_name"
else
    # Not in a tmux session, create and attach to it
    tmux new-session -s "$session_name" -c "$selected_dir"
fi


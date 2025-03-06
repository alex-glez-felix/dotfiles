#!/usr/bin/env bash

# Worktree Tmux Integration
# This script integrates the git worktree manager with tmux

# Path to the worktree manager script
WORKTREE_SCRIPT="$HOME/scripts/git-worktree-manager.sh"

# Run the worktree manager to get a worktree path
selected_worktree=$("$WORKTREE_SCRIPT")

echo "Selected worktree: '$selected_worktree'"

# Exit if no worktree was selected
if [[ -z "$selected_worktree" ]]; then
    exit 0
fi

# Check if the selected path is a directory
if [[ ! -d "$selected_worktree" ]]; then
    echo "Error: Selected path is not a directory: '$selected_worktree'"
    echo "Press any key to continue..."
    read -n 1
    exit 1
fi

# Get the basename of the directory to use as session name
# Use the parent directory and the worktree directory name to make it unique
parent_dir=$(basename "$(dirname "$selected_worktree")")
worktree_dir=$(basename "$selected_worktree")
session_name="${parent_dir}_${worktree_dir}"



# Replace any dots in the session name with underscores (tmux doesn't like dots in session names)
session_name=${session_name//./\_}

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
    tmux new-session -d -s "$session_name" -c "$selected_worktree"
    tmux switch-client -t "$session_name"
else
    # Not in a tmux session, create and attach to it
    tmux new-session -s "$session_name" -c "$selected_worktree"
fi


#!/usr/bin/env bash

# Git Worktree Manager
# Helps manage git worktrees across projects

# Base directory for all code projects
CODE_DIR="$HOME/Code"
WORKTREE_DIR="$HOME/worktrees"

# Function to select a repository
select_repository() {
    find "$CODE_DIR" -mindepth 2 -maxdepth 2 -type d | 
    grep -v "/.git$" | 
    sort |
    fzf --height 40% --reverse --prompt="Select repository: " \
        --preview="eza -h -1 --icons=always --color=always {}"
}

# Function to check if a directory is a git repository
is_git_repo() {
    git -C "$1" rev-parse --is-inside-work-tree &>/dev/null
}

# Function to list worktrees for a repository
list_worktrees() {
    local repo="$1"
    git -C "$repo" worktree list
}

# Function to select a worktree or action
select_worktree_or_action() {
    local repo="$1"
    
    # Get list of worktrees
    local worktrees=$(git -C "$repo" worktree list | awk '{print $1}')
    
    # Add actions
    echo "$worktrees"
    echo "[Create new worktree]"
    echo "[Delete worktree]"
    echo "[Cancel]"
}

# Function to create a new worktree
create_worktree() {
    local repo="$1"
    
    # Get available branches
    local branches=$(git -C "$repo" branch -a | grep -v HEAD | sed 's/^[ *]*//' | sed 's/remotes\/origin\///' | sort | uniq)
    
    # Select branch
    local branch=$(echo "$branches" | fzf --height 40% --reverse --prompt="Select branch: ")
    
    if [[ -z "$branch" ]]; then
        echo "No branch selected. Exiting."
        return 1
    fi
    
    # Use fzf as an input method for the worktree name
    local default_name="$branch"
    local worktree_name=$(echo "$default_name" | fzf --height 40% --reverse --prompt="Enter worktree name (default: $branch): " --print-query | head -1)
    
    # If empty, use the branch name
    if [[ -z "$worktree_name" ]]; then
        worktree_name="$branch"
    fi
    
    # Create the worktree
    local worktree_path="$WORKTREE_DIR/$(basename "$repo")/$worktree_name"
    
    # Use the -f flag to force creation and avoid prompts
    output=$(GIT_TERMINAL_PROMPT=0 git -C "$repo" worktree add -f "$worktree_path" "$branch" 2>&1)
    status=$?
    
    if [ $status -ne 0 ]; then
        echo "Failed to create worktree:"
        echo "$output"
        return 1
    fi
    
    # Only return the path if creation was successful
    if [ $status -eq 0 ]; then
        echo "$worktree_path"
    fi
}

# Function to delete a worktree
delete_worktree() {
    local repo="$1"
    
    # List worktrees excluding the main one
    local worktrees=$(git -C "$repo" worktree list | tail -n +2 | awk '{print $1}')
    
    if [[ -z "$worktrees" ]]; then
        echo "No additional worktrees to delete."
        echo "Press any key to continue..."
        read -n 1
        return 1
    fi
    
    # Select worktree to delete
    local selected=$(echo "$worktrees" | fzf --height 40% --reverse --prompt="Select worktree to delete: ")
    
    if [[ -z "$selected" ]]; then
        echo "No worktree selected. Exiting."
        return 1
    fi
    
    yes | GIT_TERMINAL_PROMPT=0 git -C "$repo" worktree remove "$selected"
    echo "Worktree deleted."
}

# Function to select a worktree or action
select_worktree_or_action() {
    local repo="$1"
    
    # Get list of worktrees (just the paths)
    local worktrees=$(git -C "$repo" worktree list | awk '{print $1}')
    
    # Add actions
    echo "$worktrees"
    echo "[Create new worktree]"
    echo "[Delete worktree]"
    echo "[Cancel]"
}

# Main function
main() {
    # Select repository
    local repo=$(select_repository)
    
    if [[ -z "$repo" ]]; then
        echo "No repository selected. Exiting."
        exit 0
    fi
    
    # Check if it's a git repository
    if ! is_git_repo "$repo"; then
        echo "$repo is not a git repository. Exiting."
        exit 1
    fi
    
    # Select worktree or action
    local selection=$(select_worktree_or_action "$repo" | fzf --height 40% --reverse --prompt="Select worktree or action: ")
    
    if [[ -z "$selection" ]]; then
        echo "No selection made. Exiting."
        exit 0
    fi

    # Handle selection
    case "$selection" in
        "[Create new worktree]")
            local new_worktree=$(create_worktree "$repo")
            if [[ -n "$new_worktree" ]]; then
                # Return the new worktree path for tmux integration
                echo "$new_worktree"
                exit 0
            fi
            ;;
        "[Delete worktree]")
            delete_worktree "$repo"
            echo $CODE_DIR
            exit 0
            ;;
        "[Cancel]")
            echo "Operation cancelled."
            exit 0
            ;;
        *)
            # Selected an existing worktree - just return the path
            echo "$selection"
            exit 0
            ;;
    esac
}
# Run the main function
main


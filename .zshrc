# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# History
HISTSIZE=5000
HISTFILE=~/.histfile
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# fnm
FNM_PATH="/home/alex/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

eval "$(zoxide init --cmd cd zsh)"

# Created by `pipx` on 2024-07-21 05:09:11
export PATH="$PATH:/home/alex/.local/bin"
export PATH=$PATH:$HOME/go/bin

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found

bindkey '^y' autosuggest-accept # ctrl-y to accept suggestion
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

mkcd () { mkdir "$1" && cd "$1"; }

# Aliases
alias vim='nvim'
alias v='nvim'

alias ls='eza --grid --icons'
alias ld='eza -D'
alias lf='eza -f --color=always'
alias lh='eza -d .* --group-directories-first'
alias ll='eza -a --group-directories-first'
alias lt='eza -al --sort=modified'


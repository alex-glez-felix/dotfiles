
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt notify
unsetopt autocd extendedglob
bindkey -v
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list '' '' '' ''
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' verbose false
zstyle :compinstall filename '/home/alex/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Starship
eval "$(starship init zsh)"

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

source  "$HOME/.config/commands/aliases.sh"

# fnm
FNM_PATH="/home/alex/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# Created by `pipx` on 2024-07-21 05:09:11
export PATH="$PATH:/home/alex/.local/bin"
export PATH=$PATH:$HOME/go/bin

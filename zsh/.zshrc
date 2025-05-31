# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH=$PATH:/home/ackermann/go/bin

export EDITOR="nvim"
export VISUAL="nvim"
export KEYTIMEOUT=1

bindkey -v

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi 

alias yay="paru --bottomup"
alias yeet="sudo pacman -Rns"
alias vim="nvim"
alias ll="ls -alF"
alias gg="lazygit"
alias ..="cd .."
alias ...="cd ../.."

eval "$(starship init zsh)"
autoload -Uz compinit; compinit

# ============================================================================
# Aliases
# ============================================================================
alias logpath="echo \$PATH | tr ':' '\n'"
alias yay="paru --bottomup"
alias yeet="sudo pacman -Rns"
alias vim="nvim"
alias ll="ls -alF"
alias gg="lazygit"
alias ..="cd .."
alias ...="cd ../.."

# chezmoi. `cmvim` pulls the lazy-lock.json that LazyVim just rewrote back into
# the chezmoi source dir -- `re-add` rather than `add` so it only touches files
# already managed, and never clobbers a template. It updates the source only;
# commit and push from `cm cd`.
alias cm="chezmoi"
alias cmvim='chezmoi re-add ~/.config/nvim/lazy-lock.json'

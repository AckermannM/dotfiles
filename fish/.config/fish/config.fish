source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # no fastfetch pls
end

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

starship init fish | source

alias yeet="sudo pacman -Rns"
alias yay="paru --bottomup"
alias gg="lazygit"
alias ll="ls -alF"
alias vim="nvim"

bind \cf 'commandline -r "herdr-sessionizer"; commandline -f execute'
bind \eh 'commandline -r "herdr-sessionizer ~/projects/dotfiles"; commandline -f execute'
bind \ej 'commandline -r "herdr-sessionizer ~/projects/rangedesk"; commandline -f execute'
bind \ek 'commandline -r "herdr-sessionizer ~/projects/homelab-doc"; commandline -f execute'
bind \el 'commandline -r "herdr-sessionizer ~/Downloads/"; commandline -f execute'

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:-1,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

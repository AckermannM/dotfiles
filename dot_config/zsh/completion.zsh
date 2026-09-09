# ============================================================================
# Completion (fish-like menu: descriptions, colors, arrow-key navigation)
# ============================================================================
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"
# Only do the (slow) security check once a day
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zmodload -i zsh/complist

setopt COMPLETE_IN_WORD       # complete from the cursor, not the end of the word
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt NO_LIST_BEEP
unsetopt MENU_COMPLETE        # show the menu first, don't insert blindly

# Arrow-key navigable menu, like fish's completion pager
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*:messages'     format '%F{purple}%d%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches for %d%f'
zstyle ':completion:*:corrections'  format '%F{green}%d (errors: %e)%f'

# Case-insensitive, then partial-word, then substring matching
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Cache slow completions (pacman, etc.)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

zstyle ':completion:*' rehash true            # notice newly installed commands
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other

# Escape from the completion menu with escape
bindkey -M menuselect '^[' send-break
# Shift-tab walks the menu backwards
bindkey '^[[Z' reverse-menu-complete

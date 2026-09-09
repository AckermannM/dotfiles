# ============================================================================
# Plugins — order matters:
#   syntax-highlighting -> history-substring-search -> autosuggestions
# ============================================================================
_zsh_plugins=/usr/share/zsh/plugins

# Fish-like syntax highlighting (valid commands green, invalid red, ...)
if [[ -r $_zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
  source $_zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Up/down search history for what you've already typed, like fish
if [[ -r $_zsh_plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source $_zsh_plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=black,bg=magenta,bold'
  HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
  for _km in viins vicmd; do
    bindkey -M $_km '^[[A' history-substring-search-up
    bindkey -M $_km '^[[B' history-substring-search-down
    bindkey -M $_km '^[OA' history-substring-search-up   # application cursor mode
    bindkey -M $_km '^[OB' history-substring-search-down
  done
  unset _km
  bindkey -M viins '^P' history-substring-search-up
  bindkey -M viins '^N' history-substring-search-down
  bindkey -M vicmd 'k'  history-substring-search-up      # vim-style history
  bindkey -M vicmd 'j'  history-substring-search-down
fi

# Fish-like inline autosuggestions (grey ghost text, right-arrow to accept)
if [[ -r $_zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  source $_zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  bindkey -M viins '^ ' autosuggest-accept        # ctrl-space: accept the lot
  # ctrl-right is already forward-word, which accepts one word at a time
fi

unset _zsh_plugins

# "command not found" -> suggest the package that provides it (pkgfile)
[[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]] &&
  source /usr/share/doc/pkgfile/command-not-found.zsh

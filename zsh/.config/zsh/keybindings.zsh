# ============================================================================
# Zsh Keybindings
#
# Vi mode: readline-style editing in insert mode, real Vim in command mode.
# Fixes stock zsh's missing nav keys, restrictive backspace, and slow ESC.
# ============================================================================
bindkey -v
KEYTIMEOUT=1                  # 10ms: ESC is instant instead of a 400ms wait

# Make ctrl-w / alt-backspace stop at path separators, like fish
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# --- insert mode: behaves like fish ----------------------------------------
bindkey -M viins '^?'  backward-delete-char    # backspace deletes anything
bindkey -M viins '^H'  backward-delete-char
bindkey -M viins '^W'  backward-kill-word
bindkey -M viins '^U'  backward-kill-line
bindkey -M viins '^A'  beginning-of-line
bindkey -M viins '^E'  end-of-line
bindkey -M viins '^K'  kill-line
bindkey -M viins '^Y'  yank
bindkey -M viins '^_'  undo
bindkey -M viins '^[f' forward-word
bindkey -M viins '^[b' backward-word
bindkey -M viins '^[d' kill-word

# --- nav keys bound in BOTH keymaps, so they can never drop you into cmd ----
for _km in viins vicmd; do
  bindkey -M $_km '^[[H'    beginning-of-line  # Home
  bindkey -M $_km '^[[F'    end-of-line        # End
  bindkey -M $_km '^[[1~'   beginning-of-line  # Home (alt encoding)
  bindkey -M $_km '^[[4~'   end-of-line        # End  (alt encoding)
  bindkey -M $_km '^[[3~'   delete-char        # Delete
  bindkey -M $_km '^[[1;5C' forward-word       # ctrl-right
  bindkey -M $_km '^[[1;5D' backward-word      # ctrl-left
  bindkey -M $_km '^[[1;3C' forward-word       # alt-right
  bindkey -M $_km '^[[1;3D' backward-word      # alt-left
done

# --- command mode: real vim -------------------------------------------------
# Text objects. zsh ships these widgets but binds none of them, so out of the
# box `ci"` and `da(` silently do nothing. Bind them and they work as in vim.
autoload -Uz select-bracketed select-quoted
zle -N select-bracketed
zle -N select-quoted
for _km in visual viopp; do
  for _c in {a,i}${(s..)^:-'()[]{}<>bB'}; do bindkey -M $_km "$_c" select-bracketed; done
  for _c in {a,i}${(s..)^:-\'\"\`};      do bindkey -M $_km "$_c" select-quoted;    done
done
unset _km _c

bindkey -M vicmd 'gg' beginning-of-buffer-or-history
bindkey -M vicmd 'G'  end-of-buffer-or-history
bindkey -M vicmd 'u'  undo
bindkey -M vicmd '^R' redo

# ^x^e: drop the current command line into nvim for real editing, then run it
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line

# --- mode indicator: block cursor in command mode, beam in insert -----------
# starship's [character] module already swaps its symbol per mode; this makes
# the mode visible at the cursor too. Defined BEFORE `starship init zsh` so
# starship wraps this widget rather than replacing it.
_vi_cursor() {
  case ${KEYMAP:-viins} in
    vicmd) printf '\e[2 q' ;;   # steady block
    *)     printf '\e[6 q' ;;   # steady beam
  esac
}
zle -N zle-keymap-select _vi_cursor
_vi_cursor_init() { _vi_cursor }
zle -N zle-line-init _vi_cursor_init
autoload -Uz add-zsh-hook
_vi_cursor_reset() { printf '\e[6 q' }
add-zsh-hook preexec _vi_cursor_reset

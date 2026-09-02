# ============================================================================
# History (fish-like: big, shared between sessions, deduped)
# ============================================================================
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY          # new shells see history from running shells
setopt INC_APPEND_HISTORY     # write as you go, not only on exit
setopt EXTENDED_HISTORY       # record timestamps
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates
setopt HIST_IGNORE_SPACE      # " cmd" is not recorded
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # expand !! into the buffer instead of running it

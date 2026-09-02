# ============================================================================
# Shell options
# ============================================================================
setopt AUTO_PUSHD             # keep a directory stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS   # allow `# comments` at the prompt
setopt NO_BEEP
unsetopt CORRECT CORRECT_ALL  # no "did you mean" nagging
unsetopt FLOW_CONTROL         # free up ctrl-s / ctrl-q

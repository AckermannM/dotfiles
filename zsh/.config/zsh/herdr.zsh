# ============================================================================
# herdr
# ============================================================================
bindkey -s '^f'   "herdr-sessionizer\n"
bindkey -s '\eh'  "herdr-sessionizer ~/projects/dotfiles\n"
bindkey -s '\ej'  "herdr-sessionizer ~/projects/rangedesk\n"
bindkey -s '\ek'  "herdr-sessionizer ~/projects/homelab-doc\n"
bindkey -s '\el'  "herdr-sessionizer ~/Downloads/\n"

# herdr-automatic-rename: rename the herdr tab the instant a command starts,
# instead of waiting for the next focus/tab event.
for _f in ${HOME}/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source $_f
  break
done
unset _f

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

# herdr-quit: the herdr equivalent of `exit`ing out of the last tmux session.
#
# herdr's server is persistent by design, and `herdr server stop` on its own
# writes the open workspaces to ~/.config/herdr/session.json, so the next
# launch restores them — including the lone "~" workspace we never asked for.
# Closing *every* workspace is what clears that state: herdr deletes
# session.json itself once the last workspace is gone. Then stop the server.
#
# Closing our own workspace kills the shell running this, so inside a pane the
# teardown is detached with `setsid` and outlives the pane it started from.
herdr-quit() {
  herdr status 2>/dev/null | grep -q 'status: running' || {
    print "herdr server is not running."
    return 0
  }

  local teardown='
    for ws in $(herdr workspace list 2>/dev/null | jq -r ".result.workspaces[].workspace_id"); do
      herdr workspace close "$ws" >/dev/null 2>&1
    done
    herdr server stop >/dev/null 2>&1
  '

  if [[ -n $HERDR_ENV ]]; then
    setsid -f zsh -c "$teardown"
  else
    eval "$teardown"
  fi
}
alias hq='herdr-quit'

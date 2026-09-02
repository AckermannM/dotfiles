# ============================================================================
# WSL specific entries
# ============================================================================
if [[ "$(uname -r)" == *microsoft* ]]; then
  # strip unwanted Windows paths from PATH
  PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '
    !/\/mnt\/c\/Program Files( \(x86\))?\/nodejs/ &&
    !/\/mnt\/c\/Program Files( \(x86\))?\/dotnet/ &&
    !/\/mnt\/c\/Users\/[^/]+\/AppData\/Roaming\/npm/ &&
    !/\/mnt\/c\/Users\/[^/]+\/\.dotnet/
  ' | sed 's/:$//')
  export PATH

  alias open="explorer.exe"

  # enable wsl2-ssh-agent if installed (adds 1password ssh support)
  if [[ -e /usr/sbin/wsl2-ssh-agent ]]; then
    eval "$(/usr/sbin/wsl2-ssh-agent)"
  fi

  gcm_program_path="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
  gcm_program_path_escaped="${gcm_program_path/ /\\ }"
  current_helper=$(git config --global --get credential.helper)

  if [[ -z "$current_helper" || "$current_helper" != "$gcm_program_path_escaped" ]]; then
    if [[ -x "$gcm_program_path" ]]; then
      git config --global credential.helper "$gcm_program_path_escaped"
    else
      echo "Git Credential Manager not found."
    fi
  fi
fi

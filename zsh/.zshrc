export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:/home/ackermann/go/bin
export PATH=$PATH:$HOME/.dotnet/tools

export EDITOR="nvim"
export VISUAL="nvim"
export KEYTIMEOUT=1

bindkey -v

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:-1,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

eval "$(starship init zsh)"
autoload -Uz compinit
compinit

# --- Load asdf dotnet plugin environment if available ---
if command -v asdf >/dev/null 2>&1; then
  if asdf plugin list 2>/dev/null | grep -q "^dotnet-core$"; then
    plugin_path="${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/dotnet-core/set-dotnet-home.zsh"
    if [ -f "$plugin_path" ]; then
      . "$plugin_path"
    fi
  fi
fi

# WSL specific entries
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

bindkey -s ^f "tmux-sessionizer\n"
bindkey -s '\eh' "tmux-sessionizer -s 0\n"
bindkey -s '\ej' "tmux-sessionizer -s 1\n"
bindkey -s '\ek' "tmux-sessionizer -s 2\n"
bindkey -s '\el' "tmux-sessionizer -s 3\n"

alias logpath="echo '$PATH' | tr ':' '\n'"
alias yay="paru --bottomup"
alias yeet="sudo pacman -Rns"
alias vim="nvim"
alias ll="ls -alF"
alias gg="lazygit"
alias ..="cd .."
alias ...="cd ../.."

# ============================================================================
# WSL specific entries
#
# Windows' PATH is no longer inherited. Every distro's /etc/wsl.conf carries
#
#     [interop]
#     appendWindowsPath = false
#
# (set by hand per distro — it lives outside $HOME and needs root, so chezmoi
# cannot manage it; see the WSL section of the README). Left on, WSL appends
# all ~60 entries of the Windows PATH, which drags Git-for-Windows' MSYS
# binaries (`vi`, `egrep`, `zgrep`, `shasum`, `json_pp`, `start`, `notepad`)
# and the Windows node/dotnet toolchains into the Arch shell, on top of every
# `stat` those directories cost on each completion and command lookup.
#
# What replaces it is the explicit list below: the few Windows directories
# actually wanted, plus ~/.local/bin/windows, a directory of symlinks standing
# in for the ones too big to put on PATH whole. Both are *appended* rather than
# prepended, so a Linux binary of the same name always wins the lookup.
#
# Nothing here forks a process. `$(</proc/version)`, `${path:#...}`, `[[ -d ]]`
# and the `(Ie)` subscript are all handled inside zsh; the old `uname -r` guard
# plus `awk | sed` PATH filter cost three spawns on every single shell start.
# ============================================================================
[[ -r /proc/version && "$(</proc/version)" == *[Mm]icrosoft* ]] || return 0

# Belt and braces: drop anything that came in from a Windows drive mount, so
# this file lands on the same PATH whether or not the distro's wsl.conf has
# been edited yet, and re-sourcing ~/.zshrc stays idempotent. The pattern
# matches drive mounts (/mnt/c/..., /mnt/d/...) only — a genuine Linux path
# under /mnt/wsl, such as Docker Desktop's cli-tools bind mount, is left alone.
path=( ${path:#/mnt/[a-zA-Z]/*} )

# The Windows account name, which is not the Linux one ($USER is `ackermann`).
# Single place to change if that ever moves.
_win_home=/mnt/c/Users/AckermannM

# Order is cosmetic — these are all appended behind the Linux entries.
_win_path=(
  # explorer.exe (the `open` alias below), clip.exe, cmd.exe, wsl.exe and
  # where.exe come in as symlinks from a directory of our own, NOT by putting
  # C:\Windows and C:\Windows\System32 on PATH. DrvFs reports every file as
  # mode 777, so zsh counts all 5,122 entries of those two directories as
  # commands: `hash` filled up with 3,687 .dll files, 112 .NLS tables and even
  # the wallpaper .pngs, and completing a command name walked the lot across a
  # 9p mount. Five links cost five entries. Another one is a single file in
  # dot_local/bin/windows/ — see the README.
  #
  # Windows PowerShell 5.1 is not among them: it is not in System32 either, it
  # lives in System32\WindowsPowerShell\v1.0, and pwsh 7 below covers it.
  $HOME/.local/bin/windows
  # App Execution Aliases: pwsh.exe, winget.exe, wt.exe, 1Password.exe
  $_win_home/AppData/Local/Microsoft/WindowsApps
  # `az` — a bash script that hands off to the bundled python.exe, so the CLI
  # runs Windows-side and shares %USERPROFILE%\.azure with the Windows shells.
  "/mnt/c/Program Files/Microsoft SDKs/Azure/CLI2/wbin"
  # `code` — the sh launcher, which detects $WSL_DISTRO_NAME and opens the
  # folder through the Remote-WSL extension rather than as a Windows path.
  "$_win_home/AppData/Local/Programs/Microsoft VS Code/bin"
  # docker / docker-compose / kubectl from Docker Desktop. This distro has no
  # native docker and Docker Desktop's WSL integration is off for it, so these
  # .exe shims are the only docker here. Drop this entry if that changes.
  "/mnt/c/Program Files/Docker/Docker/resources/bin"
)

for _d in $_win_path; do
  [[ -d $_d ]]              || continue   # not installed on this machine
  (( ${path[(Ie)$_d]} ))    && continue   # already there
  path+=$_d
done
unset _win_home _win_path _d

alias open="explorer.exe"

# enable wsl2-ssh-agent if installed (adds 1password ssh support)
if [[ -e /usr/sbin/wsl2-ssh-agent ]]; then
  eval "$(/usr/sbin/wsl2-ssh-agent)"
fi

# Git Credential Manager. Wants no PATH entry of its own: git is handed the
# absolute path, so this keeps working with the Windows PATH gone.
gcm_program_path="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
gcm_program_path_escaped="${gcm_program_path/ /\ }"
current_helper=$(git config --global --get credential.helper)

if [[ -z "$current_helper" || "$current_helper" != "$gcm_program_path_escaped" ]]; then
  if [[ -x "$gcm_program_path" ]]; then
    git config --global credential.helper "$gcm_program_path_escaped"
  else
    echo "Git Credential Manager not found."
  fi
fi

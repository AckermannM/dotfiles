# Dotfiles

Managed with [chezmoi](https://chezmoi.io). Source of truth is this branch;
the pre-chezmoi GNU stow layout is archived on the `main` branch.

## Bootstrap a machine

```
chezmoi init --apply https://github.com/AckermannM/dotfiles.git
```

`init` generates `~/.config/chezmoi/chezmoi.toml` from
[`.chezmoi.toml.tmpl`](./.chezmoi.toml.tmpl), asking which capabilities the
machine has (see below). `--apply` then writes the files it selected.

Day to day:

| command                | what it does                                            |
| ---------------------- | ------------------------------------------------------- |
| `chezmoi edit <file>`  | edit the source file behind a target                    |
| `chezmoi diff`         | what `apply` would change                               |
| `chezmoi apply`        | write the source state to `$HOME`                       |
| `chezmoi add <file>`   | pull a change made directly in `$HOME` back into source |
| `chezmoi cd`           | shell in the source dir, to commit and push             |

`dot_config/zsh/aliases.zsh` defines `cm` for `chezmoi`, and `cmvim` for
`chezmoi re-add ~/.config/nvim/lazy-lock.json` — pulling the lockfile back into
source after LazyVim updates plugins. Both update the source dir only; commit
and push from `cm cd`.

## Machines

Machines differ by **capability flags**, not by name. `.chezmoi.toml.tmpl` asks
for them once, stores the answers in `~/.config/chezmoi/chezmoi.toml`
(machine-local, never committed), and [`.chezmoiignore`](./.chezmoiignore)
excludes the packages a machine has no use for.

| flag      | set by     | gates                                        |
| --------- | ---------- | -------------------------------------------- |
| `wsl`     | detected   | nothing yet; available to templates          |
| `gui`     | asked once | `kitty`, `gtk-3.0`, `spotify-launcher.conf`  |
| `wayland` | asked once | `hypr`, `waybar`, `wofi`                     |
| `herdr`   | asked once | `herdr`, its two plugins, the sessionizer    |

`wsl` is read off the kernel (`.chezmoi.kernel.osrelease` contains
`microsoft`), so it is never asked and cannot drift. The rest default from it —
a WSL box is assumed headless — and `promptBoolOnce` means re-running
`chezmoi init` keeps existing answers. To change one, edit
`~/.config/chezmoi/chezmoi.toml` and `chezmoi apply`.

`zsh`, `starship` and `nvim` carry no flag: they are on every machine.

### Adding a package

Add its target paths to the right block in `.chezmoiignore`, then
`chezmoi add`. Paths for packages still sitting on the archived `main` branch
are already listed and are no-ops until their source files exist, so migrating
one of those is just `chezmoi add`.

### When a flag is not enough

A boolean answers "does this machine have X". It cannot answer "*which* X" —
`hyprland` and `hyprland-cachy` on the archive branch are two variants of the
same `~/.config/hypr` target. When that case is migrated, give the flag a value
instead of a bool (`hyprVariant = "cachy"`) and template the file, rather than
adding a second boolean.

## Packages on this branch

| package                  | target                                                       |
| ------------------------ | ------------------------------------------------------------ |
| `zsh`                    | `~/.zshrc`, `~/.config/zsh/`                                  |
| `starship`               | `~/.config/starship.toml`                                     |
| `nvim`                   | `~/.config/nvim/` (LazyVim; the old hand-rolled config is retired) |
| `herdr`                  | `~/.config/herdr/config.toml`                                 |
| `herdr-automatic-rename` | `~/.config/herdr-automatic-rename/`                           |
| `herdr-sessionizer`      | `~/.config/herdr-sessionizer/`, `~/.local/bin/herdr-sessionizer` |

Still on `main`, not yet migrated: `gtk`, `hyprland`, `hyprland-cachy`,
`kitty`, `spotify`, `waybar`, `wofi`, and the retired `nvim`, `tmux` and
`tmux-sessionizer`.

## WSL

WSL appends the whole Windows `PATH` — around sixty entries — to every Linux
shell it starts. That is how Git-for-Windows' MSYS binaries (`vi`, `egrep`,
`zgrep`, `shasum`, `json_pp`, `start`, `notepad`) and the Windows node and
dotnet toolchains end up shadowing or duplicating the native packages, and
every one of those directories is a DrvFs `stat` on each command lookup and
completion.

Turn it off per distro, as root:

```
sudo tee -a /etc/wsl.conf <<'EOF'

[interop]
appendWindowsPath = false
EOF
wsl.exe --terminate <distro>     # from Windows; the file is read at boot
```

`enabled` is left at its default, so interop still runs `.exe` files — only the
`PATH` import goes.

This is not a dotfile chezmoi can manage: `/etc/wsl.conf` sits outside `$HOME`
and needs root. It has to be redone on each new distro, and
[`dot_config/zsh/wsl.zsh`](./dot_config/zsh/wsl.zsh) is written to survive one
where it has not been — it strips `/mnt/<drive>/...` off `PATH` itself before
adding anything.

What goes back in is the explicit list in that file, appended *behind* the
Linux entries so a native binary of the same name always wins:

| directory                                      | wanted for                                                      |
| ---------------------------------------------- | --------------------------------------------------------------- |
| `~/.local/bin/windows`                         | symlinks: `explorer.exe` (the `open` alias), `clip.exe`, `cmd.exe`, `wsl.exe`, `where.exe` |
| `%LOCALAPPDATA%\Microsoft\WindowsApps`         | App Execution Aliases: `pwsh.exe`, `winget.exe`, `wt.exe`         |
| `C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin` | `az`                                                           |
| `%LOCALAPPDATA%\Programs\Microsoft VS Code\bin` | `code`                                                           |
| `C:\Program Files\Docker\Docker\resources\bin` | `docker`, `docker-compose`, `kubectl` — no native docker here     |

Deliberately absent:

- **Git Credential Manager.** Needs no `PATH` entry: `wsl.zsh` writes the
  absolute path into `credential.helper`, so it is unaffected by any of this.
- **`C:\Program Files\nodejs`, `dotnet`, `%APPDATA%\npm`, `~\.dotnet\tools`.**
  Windows toolchains in a Linux shell; asdf and pacman own these here. The
  `awk` filter `wsl.zsh` used to carry existed only to strip exactly these.
- **Git-for-Windows' `usr\bin` and `mingw64\bin`.** MSYS builds of `vi`,
  `egrep`, `zgrep`, `ssh-copy-id`, `shasum`, `json_pp` and most of perl.
  Native equivalents: `nvim`, `grep -E`, `sha1sum`, `jq`.

Windows PowerShell 5.1 is *not* in `System32` — it is two directories further
down, in `System32\WindowsPowerShell\v1.0`, which is left off deliberately:
`pwsh.exe` 7 comes in via the App Execution Aliases above.

### Why `C:\Windows` and `System32` are symlinks rather than `PATH` entries

DrvFs reports every file on a Windows drive as mode 777, so zsh treats all
5,122 files in those two directories as executables. On `PATH` they put 3,687
`.dll` files, 234 more in capitals, 112 `.NLS` tables, 71 `.png` wallpapers and
a pile of `.cpl`, `.msc` and `.tlb` into the command hash table — `${#commands}`
went from about 2,000 to **7,127** — and every command-name completion walked
the lot across a 9p mount.

So the five binaries actually wanted are symlinked into
[`dot_local/bin/windows/`](./dot_local/bin/windows) and only that directory is
put on `PATH`: five entries instead of 5,122, and the name of each link is the
whole inventory. chezmoi manages them as `symlink_` sources, gated on the `wsl`
flag in [`.chezmoiignore`](./.chezmoiignore) — on a native Linux box they would
be five dangling links.

Adding one is a file containing its target:

```
printf '/mnt/c/Windows/System32/ipconfig.exe\n' \
  > "$(chezmoi source-path)/dot_local/bin/windows/symlink_ipconfig.exe"
chezmoi apply ~/.local/bin/windows
```

[`.gitattributes`](./.gitattributes) pins those sources to LF. They hold
nothing but a path, and `core.autocrlf` on the Windows checkout would otherwise
leave a `\r` on the end of the link target.

Interop follows symlinks, so these behave exactly as they did on `PATH`,
pipes included — which is what ruled out the tidier-looking alternative of a
shell function per binary. A function is invisible to anything that is not this
zsh: `git`, `nvim`, a script.

### Interop: `.exe` fails with "Exec format error"

Running any Windows binary from a distro can fail with

```
/mnt/c/Windows/System32/cmd.exe: cannot execute binary file: Exec format error
```

even while `/proc/sys/fs/binfmt_misc/status` reports `enabled`. WSL registers
its `:WSLInterop:` handler during its own init; systemd then mounts
`binfmt_misc` over the top and the registration goes with it. Nothing puts it
back, because `systemd-binfmt.service` is `ConditionDirectoryNotEmpty` on
`/etc/binfmt.d` and `/usr/lib/binfmt.d` — both empty on a stock distro, so the
unit logs *"skipped, no trigger condition checks were met"*.

Check with `ls /proc/sys/fs/binfmt_misc/`: only `register` and `status` means
the handler is gone. Fix it by giving systemd something to do, as root:

```
cat > /etc/binfmt.d/WSLInterop.conf <<'EOF'
:WSLInterop:M::MZ::/init:PF
EOF
systemctl restart systemd-binfmt
```

Fields are name, type `M` (magic), offset, magic `MZ`, mask, interpreter
`/init`, flags `P` (preserve `argv[0]`) and `F` (open the interpreter at
registration time, so it still resolves inside mount namespaces).

Worth ruling out first when `open`, `az` or `code` "stop working" — the symptom
looks like a `PATH` problem and is not one.

`clip.exe` only copies. Pasting has no `.exe` to call — it needs
`powershell.exe -NoProfile -Command Get-Clipboard`, a whole PowerShell start,
so it is left unaliased rather than pretending to be `pbpaste`.

## Arch setup

```
pacman -S base-devel git vim nano zsh fastfetch sudo wget
```

- [paru - package manager for Arch](https://github.com/Morganamilo/paru)

```
paru -S neovim fzf ripgrep fd lazygit python python-pip openjdk-jre-headless
```

### Shell (zsh)

`zsh` is the only shell used. Everything below is a hard dependency of
`dot_config/zsh/` — each package owns a file the config sources directly, so a
missing one is a silently degraded shell rather than an error.

```
paru -S zsh zsh-autosuggestions zsh-syntax-highlighting \
        zsh-history-substring-search zsh-completions \
        starship fzf pkgfile ttf-jetbrains-mono-nerd
```

| package                        | what it provides                                                            |
| ------------------------------ | --------------------------------------------------------------------------- |
| `zsh-autosuggestions`          | grey inline suggestion from history, `→` to accept                          |
| `zsh-syntax-highlighting`      | command turns green/red as you type                                         |
| `zsh-history-substring-search` | `↑`/`↓` (and `k`/`j` in command mode) filter history by what you typed      |
| `zsh-completions`              | extra completion definitions, picked up via `/usr/share/zsh/site-functions` |
| `starship`                     | prompt, incl. the vi-mode indicator (`[character]` in `starship.toml`)      |
| `fzf`                          | `^R` history, `^T` files, `M-c` cd                                          |
| `pkgfile`                      | "command not found" -> suggests the package providing it                    |
| `ttf-jetbrains-mono-nerd`      | glyphs for the starship prompt (set as `font_family` in `kitty.conf`)       |

`pkgfile` needs its database populated once, and a timer to keep it fresh —
without this the "command not found" handler stays silent:

```
sudo pkgfile --update
sudo systemctl enable --now pkgfile-update.timer
```

## Herdr

Terminal workspace manager, replaces tmux. Config lives in
`dot_config/herdr/config.toml`.

```
paru -S herdr-bin
```

`prefix+f` opens the [herdr-sessionizer](./dot_local/bin/executable_herdr-sessionizer)
fuzzy project picker in a popup; `prefix+H/J/K/L` jump straight to a fixed
project, same as the old tmux bindings.

### herdr-automatic-rename plugin

Auto-names tabs after their focused pane's foreground program (`nvim`, `zsh`,
...) instead of a plain number, similar to tmux's `automatic-rename` +
`set-titles on`. See [qu8n/herdr-automatic-rename](https://github.com/qu8n/herdr-automatic-rename).

```
herdr plugin install qu8n/herdr-automatic-rename --yes
```

The shell hook (renames a tab the instant a command starts, instead of waiting
for the next focus/tab event) is wired up in `dot_config/zsh/herdr.zsh`.

`ui.prompt_new_tab_name = false` is already set in `config.toml` — required so a
new tab isn't immediately treated as a manual rename, which would opt it out of
automatic naming.

### Quitting herdr entirely (`hq`)

tmux dies once you `exit` out of the last session; herdr's server is persistent
by design, and `herdr server stop` alone persists the open workspaces to
`~/.config/herdr/session.json`, so the next launch restores them — the leftover
`~` workspace included.

`hq` (alias for `herdr-quit`, in `dot_config/zsh/herdr.zsh`) reproduces the tmux
behaviour: it closes *every* workspace first — herdr deletes `session.json`
itself once the last one is gone — and then stops the server, so the next
`herdr`/`herdr-sessionizer` is a genuine cold start.

Run from inside a pane it tears down the session it is running in, so the work
is detached with `setsid` and survives its own pane closing. Needs `jq`.

## Notes on 1password on Arch

For 1password to work with Yubikeys it needs

```bash
paru -S gnome-keyring libsecret polkit polkit-gnome seahorse
```

Then in seahorse create a new keyring for passwords and set it as **default**,
it will fail to save the Yubikey otherwise.

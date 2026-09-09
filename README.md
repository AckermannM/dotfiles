# Dotfiles (for Arch Linux)

> [!NOTE]
> **Archived.** These dotfiles moved to [chezmoi](https://chezmoi.io); the
> `chezmoi` branch is the live one and will replace `main`. This branch is kept
> for history and for the packages not migrated yet — `gtk`, `hyprland`,
> `hyprland-cachy`, `kitty`, `spotify`, `waybar`, `wofi` — plus the retired
> `nvim` (superseded by `nvim-lazy`), `tmux` and `tmux-sessionizer`.
>
> `zsh`, `starship`, `nvim-lazy`, `herdr`, `herdr-automatic-rename` and
> `herdr-sessionizer` are already on the `chezmoi` branch. Do not edit them
> here — they are no longer stowed, and changes made here will not reach `$HOME`.

With `pacman` install:

```
pacman -S base-devel git vim nano zsh fastfetch sudo wget
```

Things to install/configure on a new machine.

- [paru - package manager for Arch](https://github.com/Morganamilo/paru)
- <del>[tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer) (to `.local/bin`)</del> replaced by [herdr-sessionizer](./herdr-sessionizer/.local/bin/herdr-sessionizer)

With paru, install the following packages:

```
paru -S neovim fzf ripgrep fd tmux stow lazygit python python-pip openjdk-jre-headless
```

## Shell (zsh)

`zsh` is the only shell used. Everything below is a hard dependency of `zsh/.config/zsh/` — each package owns a file the config sources directly, so a missing one is a silently degraded shell rather than an error.

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

Example tmux profile:

```
bind-key -r H run-shell "~/.local/bin/tmux-sessionizer ~/projects/path1"
bind-key -r J run-shell "~/.local/bin/tmux-sessionizer ~/projects/path2/child1/"
bind-key -r K run-shell "~/.local/bin/tmux-sessionizer ~/something-else"
bind-key -r L run-shell "~/.local/bin/tmux-sessionizer ~/whatever"
```

## Herdr

Terminal workspace manager, replaces tmux. Config lives in `herdr/.config/herdr/config.toml`.

```
paru -S herdr-bin
```

### herdr-automatic-rename plugin

Auto-names tabs after their focused pane's foreground program (`nvim`, `fish`,
...) instead of a plain number, similar to tmux's `automatic-rename` +
`set-titles on`. See [qu8n/herdr-automatic-rename](https://github.com/qu8n/herdr-automatic-rename).

```
herdr plugin install qu8n/herdr-automatic-rename --yes
```

The shell hook (renames a tab the instant a command starts, instead of waiting
for the next focus/tab event) is wired up in `zsh/.config/zsh/herdr.zsh` and
`fish/.config/fish/config.fish`.

`ui.prompt_new_tab_name = false` is already set in `config.toml` — required so a
new tab isn't immediately treated as a manual rename, which would opt it out of
automatic naming.

### Quitting herdr entirely (`hq`)

tmux dies once you `exit` out of the last session; herdr's server is persistent
by design, and `herdr server stop` alone persists the open workspaces to
`~/.config/herdr/session.json`, so the next launch restores them — the leftover
`~` workspace included.

`hq` (alias for `herdr-quit`, in `zsh/.config/zsh/herdr.zsh`) reproduces the
tmux behaviour: it closes *every* workspace first — herdr deletes
`session.json` itself once the last one is gone — and then stops the server, so
the next `herdr`/`herdr-sessionizer` is a genuine cold start.

Run from inside a pane it tears down the session it is running in, so the work
is detached with `setsid` and survives its own pane closing. Needs `jq`.

## Notes on 1password on Arch

For 1password to work with Yubikeys it needs

```bash
paru -S gnome-keyring libsecret polkit polkit-gnome seahorse
```

Then in seahorse create a new keyring for passwords and set it as **default**, it will fail to save the Yubikey otherwise.

# Dotfiles (for Arch Linux)

With `pacman` install:

```
pacman -S base-devel git vim nano zsh fastfetch sudo wget
```

Things to install/configure on a new machine.

- [paru - package manager for Arch](https://github.com/Morganamilo/paru)
- [starship](https://starship.rs/)
- [tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer) (to `.local/bin`)

With paru, install the following packages:

```
paru -S neovim fzf ripgrep fd tmux stow lazygit python python-pip openjdk-jre-headless
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

The fish hook (renames a tab the instant a command starts, instead of waiting
for the next focus/tab event) is already wired up in `fish/.config/fish/config.fish`.

`ui.prompt_new_tab_name = false` is already set in `config.toml` — required so a
new tab isn't immediately treated as a manual rename, which would opt it out of
automatic naming.

## Notes on 1password on Arch

For 1password to work with Yubikeys it needs

```bash
paru -S gnome-keyring libsecret polkit polkit-gnome seahorse
```

Then in seahorse create a new keyring for passwords and set it as **default**, it will fail to save the Yubikey otherwise.

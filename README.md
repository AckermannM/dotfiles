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

# dotfiles-mint

Personal config files for **Linux Mint**, managed via `~/.config`.
Adapted from my macOS [dotfiles](https://github.com/mayorathan/dotfiles).

## Install

Clone into `~/.config` and run the installer:

```sh
git clone --recurse-submodules https://github.com/mayorathan/dotfiles-mint.git ~/.config
~/.config/install.sh
```

The script will:

- `apt install` everything in [`apt/packages.list`](apt/packages.list) — zsh, git, neovim, lsd, fzf, zoxide, ripgrep, and base tools
- Add third-party apt sources for **gh**, **lazygit** and **Ghostty** (none of these ship in Ubuntu 24.04 / Mint 22)
- Install **starship**, **atuin** and **bottom (btm)** from their official installers / release binaries (to `~/.local/bin`)
- Download the **JetBrains Mono Nerd Font** into `~/.local/share/fonts`
- Initialize the **zsh plugin** and **ghostty shader** submodules
- Symlink `~/.zshenv → ~/.config/.zshenv` and set **zsh** as the default shell

## Manual setup

If packages are already installed and you just need the shell env wired up:

```sh
ln -s ~/.config/.zshenv ~/.zshenv
```

`~/.zshenv` points zsh at this directory:

```sh
export ZDOTDIR=$HOME/.config/zsh
```

## Notes

- Targets **Linux Mint 22.x** (Ubuntu 24.04 base). Other apt-based distros should mostly work, though package availability may differ.
- `apt/packages.list` is the single source of truth for apt packages (one per line, `#` comments).
- Tools not in apt go to `~/.local/bin` (starship, atuin) or are installed via PPA / `.deb` (gh, lazygit, ghostty, bottom).

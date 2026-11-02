# dotfiles-mint

Personal config files for **Linux Mint**, managed via `~/.config`.
Adapted from my macOS [dotfiles](https://github.com/mayorathan/dotfiles).

## Install

Clone into `~/.config` and run the installer:

```sh
git clone --recurse-submodules https://github.com/mayorathan/dotfiles-mint.git ~/.config
~/.config/install.sh
```

Or, once cloned, via make:

```sh
make install
```

The installer will:

- `apt install` everything in [`apt/packages.list`](apt/packages.list) — zsh, git, neovim, lsd, fzf, zoxide, btop, ripgrep, and base tools
- Add third-party apt sources for **gh**, **lazygit** and **Ghostty** (none of these ship in Ubuntu 24.04 / Mint 22)
- Install **starship** and **atuin** from their official installers (to `~/.local/bin`)
- Download the **JetBrains Mono Nerd Font** into `~/.local/share/fonts`
- Initialize the **zsh plugin** and **ghostty shader** submodules
- Symlink `~/.zshenv → ~/.config/.zshenv` and set **zsh** as the default shell
- Print a summary of installed tools and versions

## Make targets

| Target | Action |
|--------|--------|
| `make install` | run the full installer |
| `make update`  | pull latest config + submodules |
| `make link`    | symlink `~/.zshenv` → `~/.config/.zshenv` |
| `make font`    | (re)install the JetBrains Mono Nerd Font |

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
- Tools not in apt go to `~/.local/bin` (starship, atuin) or are installed via PPA / apt repo (gh, lazygit, ghostty).

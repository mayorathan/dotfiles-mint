DOTFILES := $(HOME)/.config

.PHONY: help install update link font

help:
	@echo "dotfiles-mint"
	@echo "  make install  - run the full installer"
	@echo "  make update   - pull latest config + submodules"
	@echo "  make link     - symlink ~/.zshenv -> ~/.config/.zshenv"
	@echo "  make font     - (re)install JetBrains Mono Nerd Font"

install:
	./install.sh

update:
	git -C $(DOTFILES) pull --recurse-submodules

link:
	ln -sfn $(DOTFILES)/.zshenv $(HOME)/.zshenv
	@echo "Linked ~/.zshenv -> $(DOTFILES)/.zshenv"

font:
	@mkdir -p $(HOME)/.local/share/fonts
	curl -fsSL -o /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
	unzip -o /tmp/JetBrainsMono.zip -d $(HOME)/.local/share/fonts/JetBrainsMono
	rm -f /tmp/JetBrainsMono.zip
	fc-cache -f
	@echo "JetBrains Mono Nerd Font installed"

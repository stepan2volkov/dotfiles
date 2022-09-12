all: sync

sync:
	mkdir -p ~/.config/{alacritty,nvim}
	cp -r nvim ~./config/nvim
	cp -r alacritty ~./config/alacritty
	cp .zshrc ~/.zshrc

.PHONY: all sync

#!/bin/bash
cd ~/dotfiles

# Backup existing configs
mkdir -p ~/config-backup
cp -r ~/.bashrc ~/.emacs.d ~/.gitconfig ~/.config/kitty ~/.config/nvim ~/config-backup/ 2>/dev/null

# Remove existing configs
rm -f ~/.bashrc ~/.gitconfig
rm -rf ~/.emacs.d ~/.config/kitty ~/.config/nvim

# Deploy configurations using stow
stow bash
stow emacs
stow git
stow kitty
stow nvim

echo "Dotfiles installed successfully!"

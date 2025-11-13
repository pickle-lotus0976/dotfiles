# Dotfiles

Personal configuration files for my Linux Laptop.

## Contents

- **bash** - Bash shell configuration
- **emacs** - Emacs editor configuration
- **git** - Git version control settings
- **kitty** - Kitty terminal emulator configuration
- **nvim** - Neovim editor configuration (using lazy.nvim)

## Installation

### Prerequisites

- Git
- GNU Stow

### Setup

1. Clone this repository:
```bash
git clone https://github.com/pickle-lotus0976/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Backup existing configurations:
```bash
mkdir -p ~/config-backup
cp -r ~/.config/bash ~/.emacs.d ~/.gitconfig ~/.config/kitty ~/.config/nvim ~/config-backup/ 2>/dev/null
```

3. Remove existing configurations:
```bash
rm -rf ~/.config/bash ~/.emacs.d ~/.gitconfig ~/.config/kitty ~/.config/nvim
```

4. Deploy configurations using stow:
```bash
stow bash emacs git kitty nvim
```

Or deploy all at once:
```bash
stow */
```

## Usage

### Adding new configurations

1. Create a new directory in the dotfiles repo
2. Mirror the structure from your home directory
3. Stow the new package

### Updating configurations

Changes made to the actual config files (symlinked) are automatically reflected in the repository. Just commit and push:
```bash
cd ~/dotfiles
git add .
git commit -m "Update: description of changes"
git push
```

### Removing configurations
```bash
cd ~/dotfiles
stow -D package-name
```

## Structure

This repository uses GNU Stow for symlink management. Each subdirectory represents a "package" that can be independently deployed or removed.

## System Information

- OS: Linux Mint
- Shell: Bash
- Terminal: Kitty
- Editors: Neovim & Emacs
- Plugin Manager: lazy.nvim (Neovim)

## Notes

- Plugin directories are excluded via `.gitignore`
- Cache and temporary files are not tracked
- Configurations are version controlled for easy rollback

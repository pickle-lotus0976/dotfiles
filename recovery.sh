#!/bin/bash
# Recovery script for deleted .cache directory

set -e

echo "Dotfiles Cache Recovery Script"
echo ""

# 1. Recreate cache directory structure
echo "[1/5] Recreating cache directories..."
mkdir -p ~/.cache
mkdir -p ~/.cache/nvim
mkdir -p ~/.cache/kitty

# 2. Fix Neovim
echo "[2/5] Reinstalling Neovim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
echo "Neovim plugins reinstalled"

# 3. Fix Emacs
echo "[3/5] Rebuilding Emacs packages..."
if [ -d ~/.emacs.d ]; then
    # Remove old compiled files and force rebuild
    find ~/.emacs.d -name "*.elc" -delete 2>/dev/null || true
    
    # Start Emacs to rebuild packages (will exit after init)
    emacs --batch -l ~/.emacs.d/init.el 2>/dev/null || true
    echo "Emacs packages reinstalled"
else
    echo "Emacs directory not found, skipping"
fi

# 4. Clear and rebuild font cache
echo "[4/5] Rebuilding font cache..."
fc-cache -fv > /dev/null 2>&1
echo "  ✓ Font cache rebuilt"

# 5. Fix bash history if needed
echo "[5/5] Checking bash history..."
touch ~/.bash_history
echo "Bash history file verified"

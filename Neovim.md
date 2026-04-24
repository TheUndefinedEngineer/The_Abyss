*23-04-2026* 

Installing neovim:
```bash
git clone https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install
```
or:
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage
```

Installing kickstart.nvim:
```bash
git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

Then run:
```bash
nvim
//After all the installations
:qa
nvim
:e $MYVIMRC
```

Add quick esc shortcut in `~/.config/nvim/init.lua`:
```
vim.keymap.set('i', ';;', '<Esc>', { noremap = true, silent = true })
```

Movement Keys :
- h - move left
- j - move down
- k - move up
- l - move right

Commands:
- :q - quit
- :w - write
- dd - delete
- u - undo
- yy - copy line (yanks)

---
## !
Sources:

Tags:
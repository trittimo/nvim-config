# NVIM Config
## Installation
```sh
cd ~/.config/
git clone git@github.com:trittimo/nvim-config.git nvim
```

## bashrc
```sh
nvim-config-save() {
    if [ -z "$1" ]; then
        echo "Error: No commit message passed" >&2
        return 1
    fi
    git -C ~/.config/nvim/ add .
    git -C ~/.config/nvim/ commit -m "$1"
    git -C ~/.config/nvim/ push
}

nvim-config-load() {
    git -C ~/.config/nvim/ pull
}

nvim-install() {
    rm -r build/
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/opt/dev/neovim-env"
    make install
}
```

## Setup
### ctags
*Mac*: `brew install --HEAD universal-ctags/universal-ctags/universal-ctags`

*Windows*: `TODO`

### LSPs
#### Mac
*Lua* `brew install lua-language-server`

## Paths
*Mac*: `~/.config/nvim`

*Windows*: `TODO`



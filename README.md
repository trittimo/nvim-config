# NVIM Config
## Installation
```sh
cd ~/.config/
git clone git@github.com:trittimo/nvim-config.git nvim
```

## Adding Plugins
Plugins are cloned locally as a subtree to ensure they always work like I expect, and if an author decides to be rude and delist their plugin someday it doesn't matter.

```sh
# Example:
git subtree add --prefix plugins/tinted-theming/tinted-vim 'https://github.com/tinted-theming/tinted-vim' main --squash
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



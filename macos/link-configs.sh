#!/bin/zsh
set -euo pipefail
umask 077
[[ $OSTYPE == darwin* ]] || { print -u2 'This installer is for macOS only.'; exit 1; }
repo=${0:A:h:h}
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/shell-config/backups/$(date +%Y%m%d-%H%M%S)-$$"

link_config() {
    local source=$1 destination=$2
    [[ -e $source ]] || { print -u2 "Missing source: $source"; return 1; }
    if [[ -L $destination && ${destination:A} == ${source:A} ]]; then
        return
    fi
    mkdir -p "${destination:h}"
    if [[ -e $destination || -L $destination ]]; then
        local backup="$backup_root/${destination#$HOME/}"
        mkdir -p "${backup:h}"
        mv "$destination" "$backup"
        print -r -- "Backed up $destination to $backup"
    fi
    ln -s "$source" "$destination"
    print -r -- "Linked $destination"
}

# A previous init.lua wins over init.vim and cannot coexist with it.
if [[ -e $config_home/nvim/init.lua || -L $config_home/nvim/init.lua ]]; then
    mkdir -p "$backup_root/nvim"
    mv "$config_home/nvim/init.lua" "$backup_root/nvim/init.lua"
    print -r -- "Backed up init.lua to $backup_root/nvim/init.lua"
fi
link_config "$repo/.zprofile" "$HOME/.zprofile"
# Migrate the old repository symlink once. Local startup files remain user-owned.
zshrc_file="$HOME/.zshrc"
if [[ -L $zshrc_file && ${zshrc_file:A} == "$repo/.zshrc" ]]; then
    mkdir -p "$backup_root"
    mv "$HOME/.zshrc" "$backup_root/.zshrc"
    print -r -- "Backed up ~/.zshrc symlink to $backup_root/.zshrc"
fi
if [[ ! -e $HOME/.zshrc && ! -L $HOME/.zshrc ]]; then
    template=$(<"$repo/macos/zshrc.local")
    print -r -- "${template//__SHELL_REPO__/${(q)repo}}" > "$HOME/.zshrc"
    print 'Created local ~/.zshrc; future runs preserve your edits.'
else
    print 'Preserved existing local ~/.zshrc.'
    print -r -- "Load shared settings after Oh My Zsh with: source ${(q)repo}/.zshrc"
fi
if [[ ! -e $HOME/.p10k.zsh && ! -L $HOME/.p10k.zsh ]]; then
    cp "$repo/macos/p10k.zsh" "$HOME/.p10k.zsh"
fi
# login(1) checks this per-user marker before the shell starts.
hushlogin_file="$HOME/.hushlogin"
if [[ -L $hushlogin_file && ${hushlogin_file:A} == "$repo/macos/hushlogin" ]]; then
    mkdir -p "$backup_root"
    mv "$hushlogin_file" "$backup_root/.hushlogin"
fi
if [[ ! -e $hushlogin_file && ! -L $hushlogin_file ]]; then
    : > "$hushlogin_file"
    print 'Created regular ~/.hushlogin marker.'
fi
link_config "$repo/macos/tmux.conf" "$HOME/.tmux.conf"
link_config "$repo/macos/aerospace.toml" "$HOME/.aerospace.toml"
# Preserve an existing SwiftBar plugin folder; an unset preference is normal.
swiftbar_dir=$(/usr/bin/defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null) \
    || swiftbar_dir="$config_home/swiftbar"
link_config "$repo/macos/swiftbar/aerospace.1s.py" "$swiftbar_dir/aerospace.1s.py"
/usr/bin/defaults write com.ameba.SwiftBar PluginDirectory -string "$swiftbar_dir"
link_config "$repo/terminal/kitty.conf" "$config_home/kitty/kitty.conf"
link_config "$repo/terminal/kitty-macos.conf" "$config_home/kitty/kitty-macos.conf"
link_config "$repo/nvim/init.vim" "$config_home/nvim/init.vim"
link_config "$repo/nvim/vim-init.lua" "$config_home/nvim/lua/vim-init.lua"
link_config "$repo/nvim/plugins.lua" "$config_home/nvim/lua/plugins.lua"
link_config "$repo/nvim/markdown.snippets" "$config_home/nvim/UltiSnips/markdown.snippets"
link_config "$repo/nvim/lazy-lock.json" "$config_home/nvim/lazy-lock.json"

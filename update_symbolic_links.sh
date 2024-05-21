#! /bin/zsh

set -e
basedir=$(readlink -f $(dirname $0))

# The two most basic config files
mkdir -p $HOME/.config/nvim/lua
ln -sf $basedir/nvim/init.vim $HOME/.config/nvim
ln -sf $basedir/nvim/vim-init.lua $HOME/.config/nvim/lua
mkdir -p $HOME/.config/nvim/UltiSnips
ln -sf $basedir/nvim/markdown.snippets $HOME/.config/nvim/UltiSnips

ln -sf $basedir/.zprofile $HOME
mkdir -p $HOME/.config/kitty
ln -sf $basedir/terminal/kitty.conf $HOME/.config/kitty/
mkdir -p $HOME/.config/alacritty
ln -sf $basedir/terminal/alacritty.yml $HOME/.config/alacritty

mkdir -p $HOME/.local/bin
ln -sf $basedir/terminal/gnome-terminal $HOME/.local/bin
if [[ ! -f /etc/alternatives/x-terminal-emulator && -f /usr/bin/kitty ]]; then
	echo "Set kitty as defult terminal"
	sudo mkdir -p /etc/alternatives
	sudo ln -sf /usr/bin/kitty /etc/alternatives/x-terminal-emulator
fi

# The desktop dir
mkdir -p $HOME/.local/share/applications
cp $basedir/desktop/* $HOME/.local/share/applications

# The config dir
mkdir -p $HOME/.config/clash
ln -sf $basedir/config/clash.yaml $HOME/.config/clash

mkdir -p $HOME/.config/fcitx5/conf
ln -sf $basedir/config/fcitx5.conf $HOME/.config/fcitx5/config
ln -sf $basedir/config/fcitx5_classicui.conf $HOME/.config/fcitx5/conf/classicui.conf
ln -sf $basedir/config/fcitx5_pinyin.conf $HOME/.config/fcitx5/conf/pinyin.conf
# Profile is always rewritten by fcitx5, it seems we must need a GUI to configure it.
# This config is thus not reliable.
cp $basedir/config/fcitx5.profile $HOME/.config/fcitx5/profile

if [[ ! -f /etc/pam.d/ly ]]; then
	echo "Install ly pam config"
	sudo cp $basedir/config/ly /etc/pam.d
elif ! cmp $basedir/config/ly /etc/pam.d/ly; then
	echo "Restore ly pam config"
	sudo cp $basedir/config/ly /etc/pam.d
fi

mkdir -p $HOME/.goldendict/styles
ln -sf $basedir/config/goldendict.xml $HOME/.goldendict/config
rm -rf $HOME/.goldendict/styles/Darktheme
ln -sf $basedir/config/goldendict_Darktheme $HOME/.goldendict/styles/Darktheme
ln -sf $basedir/config/goldendict_Darktheme/article-script.js $HOME/.goldendict/

if [[ ! -f $HOME/.config/mimeapps.list ]]; then
	echo "Install mimeapps.list"
	cp $basedir/desktop/mimeapps.list $HOME/.config/mimeapps.list
	ln -sf $HOME/.config/mimeapps.list $HOME/.local/share/applications/mimeapps.list
elif ! cmp $basedir/desktop/mimeapps.list $HOME/.config/mimeapps.list; then
	echo "Update mimeapps locally"
	cp $HOME/.config/mimeapps.list $basedir/desktop/mimeapps.list
fi

if [[ -d $HOME/Documents/Project/qutebrowser ]]; then
	mkdir -p $HOME/.local/bin
	ln -sf $basedir/archives/qutebrowser $HOME/.local/bin
fi
mkdir -p $HOME/.config/qutebrowser
ln -sf $basedir/config/qutebrowser-config.py $HOME/.config/qutebrowser/config.py

if [[ ! -f /etc/NetworkManager/dispatcher.d/wifi_login ]]; then
	echo "Install wifi_login hook"
	sudo cp $basedir/config/wifi_login /etc/NetworkManager/dispatcher.d
elif ! cmp $basedir/config/wifi_login /etc/NetworkManager/dispatcher.d/wifi_login; then
	echo "Restore wifi_login hook"
	sudo cp $basedir/config/wifi_login /etc/NetworkManager/dispatcher.d
fi

mkdir -p $HOME/.config/zathura
ln -sf $basedir/config/zathurarc $HOME/.config/zathura

# Config sway
mkdir -p $HOME/.config/sway
ln -sf $basedir/sway/sway.config $HOME/.config/sway/config
if [[ $(hostnamectl hostname) == "imt.xyz" ]]; then
	ln -sf $basedir/sway/fr_kb_sway.conf $HOME/.config/sway/input
	ln -sf $basedir/sway/fr_kb.layout $HOME/.xkb/symbols/fr
fi
rm -rf $HOME/.config/waybar
ln -sf $basedir/sway/waybar $HOME/.config/waybar

#! zsh

# Set up Termux environment on Android phones
# Run it from the desktop to transfer config files

set -e
if [[ $USER == "jing" ]]; then
	adb shell rm -rf /sdcard/Download/init
	adb shell mkdir /sdcard/Download/init
	adb push scripts/misàjour /sdcard/Download/init
	adb push terminal/termux_wifirst /sdcard/Download/init
	adb push terminal/termux_proxy /sdcard/Download/init
	adb push nvim/init.vim /sdcard/Download/init
	adb push nvim/markdown.snippets /sdcard/Download/init
	adb push terminal/termux-url-opener /sdcard/Download/init
	adb push termux_init.sh /sdcard/Download/init
	adb push config/clash.yaml /sdcard/Download/init
	adb push .zshrc /sdcard/Download/init
	adb push $HOME/.ssh/id_rsa.pub /sdcard/Download/init
	adb push $HOME/.config/rclone/rclone.conf /sdcard/Download/
	[[ -e /tmp/nvim.zip ]] || 7z a -xr'!.*' /tmp/nvim.zip $HOME/.local/share/nvim/site/pack/theme $HOME/.local/share/nvim/site/pack/plugin
	adb push /tmp/nvim.zip /sdcard/Download/init
	adb shell am start -n com.termux/.HomeActivity
	sleep 1
	echo "Please allow storage access from the phone screen"
	adb shell input text 'termux-setup-storage'
	adb shell input keyevent ENTER
	sleep 1
	adb shell input keyevent ENTER
	sleep 2
	adb shell input text 'bash'
	adb shell input keyevent SPACE
	adb shell input text 'storage/downloads/init/termux_init.sh'
	adb shell input keyevent ENTER
	exit
fi

[[ -e $HOME/init ]] && rm -rf init
[[ -e storage/downloads/init ]] && mv storage/downloads/init $HOME
chmod +x $HOME/init/*
chmod -x $HOME/init/*.*
rm -rf $HOME/.local/share/nvim/
mkdir -p $HOME/.local/share/nvim/site/pack
command -v unzip && unzip $HOME/init/nvim.zip -d $HOME/.local/share/nvim/site/pack
rm -rf $HOME/init/nvim.zip
[[ -e $HOME/.config/rclone/rclone.conf ]] && rm storage/downloads/rclone.conf && exit

apt update && yes | apt upgrade && apt update
apt install -y git tsu nodejs lua53 python apt-file curl wget jq neovim zsh openssh at
chsh -s zsh
apt-file update
cat $HOME/init/id_rsa.pub >$HOME/.ssh/authorized_keys
sshd
[[ -e $HOME/init/nvim.zip ]] && unzip $HOME/init/nvim.zip -d $HOME/.local/share/nvim/site/pack

git config --global user.email "jingmatrix@gmail.com"
git config --global user.name "JingMatrix"

[[ -e ".oh-my-zsh" ]] || git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh .oh-my-zsh
chsh -s $HOME/../usr/bin/zsh
pushd .oh-my-zsh/custom/plugins/
[[ -e "z.lua" ]] || git clone --depth 1 https://github.com/skywind3000/z.lua
[[ -e "zsh-syntax-highlighting" ]] || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting
[[ -e "zsh-completions" ]] || git clone --depth 1 https://github.com/zsh-users/zsh-completions
popd

mkdir -p $HOME/.local/bin
ln -sf $HOME/init/.zshrc $HOME
ln -sf $HOME/init/termux_wifirst $HOME/.local/bin/wifirst
ln -sf $HOME/init/termux_proxy $HOME/.local/bin/proxy
ln -sf $HOME/init/misàjour $HOME/.local/bin/
mkdir -p $HOME/.config/nvim/UltiSnips
ln -sf $HOME/init/markdown.snippets $HOME/.config/nvim/UltiSnips

mkdir -p $HOME/.config/nvim
ln -sf $HOME/init/init.vim $HOME/.config/nvim

mkdir -p $HOME/bin
ln -sf $HOME/init/termux-url-opener $HOME/bin
ln -sf $PREFIX/bin/nvim $HOME/bin/termux-file-editor

mkdir -p $HOME/.local/go $HOME/.local/gem

apt install -y golang ruby tor i2pd
go install github.com/Dreamacro/clash@latest
gem install colorls

mkdir -p $HOME/.config/clash
ln -sf $HOME/init/clash.yaml $HOME/.config/clash/config.yaml

mkdir -p $HOME/Project
pushd $HOME/Project
[[ -e $HOME/Project/ZeroTierOne ]] || git clone --depth 1 https://github.com/JingMatrix/ZeroTierOne -b termux-build
popd
apt install -y cmake rust nlohmann-json binutils
pushd $HOME/Project/ZeroTierOne
make -j 2
make install
popd

go install mvdan.cc/sh/v3/cmd/shfmt@latest
apt install -y ripgrep ninja lua-language-server
apt install -y fzf nnn yarn
yarn global add vim-language-server neovim
gem install neovim
pip install neovim

apt install -y newsboat syncthing
mkdir -p $HOME/Notes/.stfolder

apt install -y rclone
mkdir -p $HOME/.config/rclone
mv storage/downloads/rclone.conf $HOME/.config/rclone
rclone sync drive:Reading $HOME/storage/shared/Documents/Reading && rclone sync drive:Mathematics $HOME/storage/shared/Documents/Mathematics

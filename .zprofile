export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export GLFW_IM_MODULE=ibus

PATH="$HOME/.local/bin:/usr/local/bin:/bin:/usr/local/sbin:/sbin:/usr/local/games:/usr/games:/usr/local/texlive/2023/bin/x86_64-linux"
function fbterm {
	fbv -ciuker /var/tmp/background.jpeg <<<q
	export FBTERM_BACKGROUND_IMAGE=1
	/bin/fbterm $@
}
export PERL_MB_OPT="--install_base \"/home/jing/.local/perl5\""
export PERL_MM_OPT="INSTALL_BASE=/home/jing/.local/perl5"
export PERL5LIB="/home/jing/.local/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export ANDROID_HOME=$HOME/Archives/Android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/gem/bin"
export GEM_HOME="$HOME/.local/gem"
export GOPATH="$HOME/.local/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$HOME/Documents/Code/Shell/scripts:$PATH"
export PATH="$PATH:$HOME/.local/perl5/bin"
export PATH="$PATH:$HOME/.local/google-cloud-sdk/bin"
export DENO_INSTALL="/home/jing/.deno"
export PATH="$PATH:$DENO_INSTALL/bin:"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$PATH:$HOME/.local/python/bin/"
export QT_QPA_PLATFORMTHEME=qt5ct
export SWAY_INTERACTIVE_SCREENSHOT_SAVEDIR=$HOME/Images/Screenshots


if [[ -z $DBUS_SESSION_BUS_ADDRESS ]]; then
	dbus-update-activation-environment --systemd --all
	[[ -z $DBUS_SESSION_BUS_ADDRESS ]] && export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
fi

# export $(gnome-keyring-daemon --start --components=ssh)

if [[ $OSTYPE == darwin* ]]; then
	source "${${(%):-%N}:A:h}/macos/env.zsh"
	return
fi

export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx

export GTK_THEME=Adwaita:dark

# Wholesale reset, so ~/.zshrc re-adds vendor_perl/core_perl afterwards.
# -U keeps every later prepend in this file idempotent: without it a
# nested login shell appends its entries a second time.
typeset -U path
PATH="$HOME/.local/bin:/usr/bin:/sbin"

# Styled framebuffer console, run by hand after a tty login (Ctrl+Alt+F1-F6).
# The bare Linux VT only has the kernel's built-in 8x16 font, which on this
# machine's 1920x1080 KMS console (amdgpudrmfb) is 240x67 cells of unreadable
# text and cannot draw CJK at all. fbterm renders its own fontconfig/freetype
# text straight onto /dev/fb0 instead; the styling lives in ~/.fbtermrc
# (config/fbtermrc in this repo).
#
# Deliberately not exec'd automatically from this file: sway is started from a
# tty login too (it is on tty2 right now), and it would fight fbterm for the
# framebuffer.
#
# Prerequisites, none of which is automatic:
#   * fbterm (AUR) -- not in the official repos
#   * sudo setcap cap_sys_tty_config+ep /usr/bin/fbterm   (its Ctrl+Alt hotkeys
#     rewrite the kernel keymap, which needs that capability)
#   * sudo usermod -aG video jing + re-login -- /dev/fb0 is root:video and
#     carries no udev "uaccess" tag, so logind grants no per-session ACL for it
#     (unlike /dev/dri/card1, which does get one)
#   * fbv (AUR) only for the background image
function fbterm {
	if (( ! $+commands[fbterm] )); then
		print -u2 "fbterm: not installed (AUR); console stays on the kernel font"
		return 127
	fi
	if [[ ! -r /dev/fb0 || ! -w /dev/fb0 ]]; then
		print -u2 "fbterm: cannot open /dev/fb0 -- are you in the 'video' group?"
		return 1
	fi

	# fbterm has no image decoder: it screenshots the framebuffer on startup
	# and uses that as the text background, so something else has to paint it
	# first. fbv is the viewer upstream documents, because -k leaves the image
	# on screen when it exits; fbi clears on exit and cannot stand in for it.
	local bg=${FBTERM_BG:-$HOME/.config/fbterm/background.jpeg}
	if [[ -r $bg ]] && (( $+commands[fbv] )); then
		print -n $'\e[?25l'               # hide the cursor while painting
		fbv -ciuker "$bg" <<<q >/dev/null 2>&1 &&
			export FBTERM_BACKGROUND_IMAGE=1
	fi

	command fbterm "$@"
}

export ANDROID_HOME=$HOME/Archives/Android
# No $ANDROID_HOME/emulator: no emulator binary was ever installed, here or
# on imt.xyz. Re-add it if you ever `sdkmanager --install emulator`.
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/gem/bin"
export GEM_HOME="$HOME/.local/gem"
# GOPATH stays (go reads it); $GOPATH/bin does not exist because nothing has
# ever been `go install`ed here. Put it back when something is.
export GOPATH="$HOME/.local/go"
export PATH="$HOME/Documents/Code/Shell/scripts:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PATH"
# export QT_QPA_PLATFORMTHEME=qt5ct
export SWAY_INTERACTIVE_SCREENSHOT_SAVEDIR=$HOME/Images/Screenshots

if [[ -z $DBUS_SESSION_BUS_ADDRESS ]]; then
	dbus-update-activation-environment --systemd --all
	[[ -z $DBUS_SESSION_BUS_ADDRESS ]] && export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
fi

# export $(gnome-keyring-daemon --start --components=ssh)
if [[ $USER == jing ]]; then
	pyenv=$HOME/.local/python/bin/pip3
	if [[ -e $pyenv ]]; then
		alias pip=$pyenv
		alias pyenv=$HOME/.local/python/bin/python3
		export PATH="$HOME/.local/python/bin:$PATH"
		# Never append unguarded. `"$PYTHONPATH:..."` on an unset PYTHONPATH
		# leaves a *leading empty element*, which python reads as the current
		# working directory and puts on sys.path. That matters for a script
		# living outside the CWD: `python3 /elsewhere/prog.py` run from a
		# directory holding a stray ./json.py imported that instead of the
		# stdlib (measured). It also re-appended itself on every nested login
		# shell, so the value grew without bound.
		# Build an array instead: (u) de-duplicates and (s.:.) drops empties.
		# The version is globbed rather than hardcoded as 3.14, so a python
		# minor bump does not silently orphan the path.
		pysite=($HOME/.local/python/lib/python*/site-packages(Nn/))
		if (( $#pysite )); then
			typeset -a pp
			pp=(${pysite[-1]} ${(s.:.)PYTHONPATH})
			export PYTHONPATH=${(j.:.)${(u)pp}}
			unset pp
		fi
		unset pysite
	else
		alias pip=pip3
	fi
fi

touch $HOME/.hushlogin

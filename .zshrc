export ZSH="$HOME/.oh-my-zsh"
plugins=(git vi-mode pip gradle)
# plugins+=(yarn urltools rust pass ripgrep nmap gradle)
plugins+=(z.lua)
plugins+=(zsh-interactive-cd)
plugins+=(zsh-syntax-highlighting zsh-completions)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
ZSH_THEME=${ZSH_THEME:-random}
source $ZSH/oh-my-zsh.sh

function ocr {
	if [[ $(wl-paste --list-types | head -1) =~ ^image ]]; then
		wl-paste -t image/png >/tmp/clip.png
	else
		echo "No images in clipboard, try images on disk"
	fi
	if [[ -f /tmp/clip.png ]]; then
		tesseract /tmp/clip.png - -l $1 quiet | head -n -1 | wl-copy
		wl-paste
	else
		echo "No images on disk, please take a new screenshot"
		grim -g "$(slurp -d)" /tmp/clip.png
		ocr $1
	fi
}

function _ocr {
	local -a ocr_langs
	ocr_langs=('chi_sim:Simplified Chinese'
		'chi_tra:Traditional Chinese'
		'eng:English'
		'fra:French')
	_describe ocr ocr_langs
}

function qb {
	[[ $1 = -* ]] || search_text=$(echo -n $@ | tr '\n' ' ')
	_ipc_socket="${XDG_RUNTIME_DIR}/qutebrowser/ipc-$(echo -n "$USER" | md5sum | cut -d' ' -f1)"
	_proto_version=1
	_qb_version=unkonwn
	_qb_window=$(swaymsg -r -t get_tree | grep '  "app_id": "org.qutebrowser.qutebrowser",$')

	if [[ -n ${_qb_window} && -e ${_ipc_socket} && -n ${search_text} ]]; then
		# An instance is runing and we want to do a search
		# We use socat and write log to /dev/null
		printf '{"args": ["%s"], "target_arg": null, "version": "%s", "protocol_version": %d, "cwd": "%s"}\n' \
			"${search_text}" \
			"${_qb_version}" \
			"${_proto_version}" \
			"${PWD}" | socat -lf /dev/null - UNIX-CONNECT:"${_ipc_socket}"
		swaymsg workspace qb
	elif [[ -z ${search_text} && -n $@ ]]; then
		# Not doing a search, this is possible for debugging uses.
		# We must start a new instance and exit.
		qutebrowser $@
		exit
	else
		nohup qutebrowser ${search_text} 1>/dev/null 2>&1 &
		disown
	fi
}

compdef _ocr ocr

alias gcl="git clone --recursive --shallow-submodules --depth 1"
if [[ $TERM == xterm-kitty ]]; then
	alias ls="ls --color --hyperlink=auto"
	alias l="colorls -al --hyperlink"
	alias rg="kitty +kitten hyperlinked_grep"
else
	alias ls="ls --color"
	alias l="colorls -al"
fi

export MANPAGER='nvim +Man!'
export MUTTBOX="gmail"
export PAGER="less -P?n -R"

# keybinding
function keep-buffer {
	if [[ $USER == jing ]]; then
		wl-copy -p $BUFFER
	else
		termux-clipboard-set $BUFFER
	fi
	BUFFER=''
}
function start_tmux {
	BUFFER='tmux attach || tmux'
}

zle -N keep-buffer
zle -N start_tmux
bindkey "^Y" redo
bindkey "^Z" undo
bindkey "^F" run-help
bindkey "^K" keep-buffer
bindkey "^H" backward-kill-word
bindkey "^B^B" start_tmux

# zsh-highlight

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[cursor]=bold

if [[ $USER == jing ]]; then
	export ANDROID_HOME=$HOME/Archives/Android
	export JDTLS_HOME=$HOME/Archives/Data/jdtls
	export KALDI_ROOT=$HOME/Documents/Project/kaldi
	export PATH="$PATH:/opt/gradle/gradle-8.1.1/bin"
	alias icat="kitty +kitten icat"
	pyenv=$HOME/.local/python/bin/pip3
	if	[[ -e $pyenv ]]; then
		alias pip=$pyenv
		alias pyenv=$HOME/.local/python/bin/python3
	else
		alias pip=pip3
	fi
	alias msfconsole="TERM=xterm-256color msfconsole"
	alias luamake=$HOME/Documents/Project/lua-language-server/3rd/luamake/luamake
	unalias gradle

	[[ -z $ALACRITTY_WAYLAND ]] || export WAYLAND_DISPLAY=$ALACRITTY_WAYLAND

else
	export PATH=$PREFIX/bin:$PREFIX/sbin:$HOME/.local/bin
	export PATH=$PATH:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin
	export GEM_HOME="$HOME/.local/gem"
	export GOPATH="$HOME/.local/go"
	export PATH="$PATH:$HOME/.cargo/bin"
	export PATH="$PATH:$GEM_HOME/bin"
	export PATH="$PATH:$GOPATH/bin"
	alias vim=nvim
	export BROWSER=termux-open-url
fi

if [[ $TERM == linux ]]; then
	export TERM=fbterm
fi

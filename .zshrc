plugins+=(git nvm vi-mode pip gradle)
# plugins+=(yarn urltools rust pass ripgrep nmap gradle)
plugins+=(z.lua)
plugins+=(zsh-interactive-cd) 
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
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
		gnome-screenshot -f /tmp/clip.png -a
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

compdef _ocr ocr

# alias sg="TERM=xterm googler -n 5"
# alias sd="TERM=xterm ddgr -n 5"
alias gcl="git clone --recursive --shallow-submodules --depth 1"
# alias john="/home/jing/Documents/Project/john/run/john"
alias lc=colorls
alias ls="ls --color --hyperlink=auto"
alias l="colorls -al --hyperlink"
alias icat="kitty +kitten icat"
alias qb=qutebrowser
alias pip=pip3
alias msfconsole="TERM=xterm-256color msfconsole"

export ANDROID_HOME=$HOME/Archives/Android
export MANPAGER='nvim +Man!'
export MUTTBOX="gmail"
export GEM_HOME="$HOME/.local/gem"
export JDTLS_HOME=$HOME/Archive/Data/jdtls
export KALDI_ROOT=$HOME/Documents/Project/kaldi
export PAGER="less -P?n -R"

# keybinding
function keep-buffer {
	wl-copy -p $BUFFER
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

[[ -z $ALACRITTY_WAYLAND ]] || export WAYLAND_DISPLAY=$ALACRITTY_WAYLAND

# zsh-highlight

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[cursor]=bold

source /home/jing/Documents/Project/nnn/misc/quitcd/quitcd.bash_zsh

if [[ $TERM == linux ]]; then
	export TERM=fbterm
fi

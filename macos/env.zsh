# Used by both login and interactive shells. Never replace the inherited PATH.
if [[ -z ${HOMEBREW_PREFIX:-} ]] || (( ! $+commands[brew] )); then
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

typeset -gU path fpath
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export GOPATH=${GOPATH:-$HOME/.local/go}
export NPM_CONFIG_PREFIX=${NPM_CONFIG_PREFIX:-$HOME/.local/share/npm}
export GEM_HOME=${GEM_HOME:-$HOME/.local/gem}
export PNPM_HOME=${PNPM_HOME:-$HOME/.local/share/pnpm}
[[ ! -d $XDG_DATA_HOME/zsh/site-functions ]] || fpath=("$XDG_DATA_HOME/zsh/site-functions" $fpath)

path=("$HOME/.local/bin" "$NPM_CONFIG_PREFIX/bin" "$PNPM_HOME" "$GEM_HOME/bin" "$HOME/.cargo/bin" "$GOPATH/bin" $path)
path=("${(@)path:#/usr/local/go/bin}")
if [[ -n $HOMEBREW_PREFIX ]]; then
    [[ ! -d $HOMEBREW_PREFIX/opt/node@24/bin ]] || path=("$HOMEBREW_PREFIX/opt/node@24/bin" $path)
    [[ ! -d $HOMEBREW_PREFIX/opt/rustup/bin ]] || path=("$HOMEBREW_PREFIX/opt/rustup/bin" $path)
    if [[ -d $HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home ]]; then
        export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
        path=("$JAVA_HOME/bin" $path)
    fi
    # Expose clangd/clang-format/lldb-dap without overriding Apple's clang/lldb.
    [[ ! -d $HOMEBREW_PREFIX/opt/llvm/bin ]] || path+=("$HOMEBREW_PREFIX/opt/llvm/bin")
    [[ ! -d $HOMEBREW_PREFIX/opt/lldb/bin ]] || path+=("$HOMEBREW_PREFIX/opt/lldb/bin")
    [[ ! -d $HOMEBREW_PREFIX/share/zsh-completions ]] || fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
fi
export PATH

# Keep project-specific tools available when their projects exist on this Mac.
[[ ! -d $HOME/Documents/Project/kaldi ]] || export KALDI_ROOT="$HOME/Documents/Project/kaldi"
if [[ -d $HOME/Library/Android/sdk ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [[ -d $HOME/Archives/Android ]]; then
    export ANDROID_HOME="$HOME/Archives/Android"
fi
if [[ -n ${ANDROID_HOME:-} && -d $ANDROID_HOME ]]; then
    path=("$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator" $path)
    [[ ! -d $ANDROID_HOME/build-tools/37.0.0 ]] || path=("$ANDROID_HOME/build-tools/37.0.0" $path)
    if [[ -d $ANDROID_HOME/ndk/30.0.16248370 ]]; then
        export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/30.0.16248370"
        export NDK_HOME=$ANDROID_NDK_HOME
    fi
fi
# Nested shells must continue using an already activated Python environment.
if [[ -n ${VIRTUAL_ENV:-} && -d $VIRTUAL_ENV/bin ]]; then
    path=("$VIRTUAL_ENV/bin" $path)
fi

if (( $+commands[nvim] )); then
    export EDITOR=nvim VISUAL=nvim
    export MANPAGER='nvim +Man!'
fi
export PAGER='less -R'
export MUTTBOX=gmail
export BROWSER=open
# Use native macOS Trash instead of Linux's trash-cli (NNN_TRASH=1).
export NNN_TRASH=/usr/bin/trash
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

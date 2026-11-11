#!/bin/zsh
# Re-runnable: install dependencies, then back up and link configuration.
set -euo pipefail
[[ $OSTYPE == darwin* ]] || { print -u2 'This installer is for macOS only.'; exit 1; }
repo=${0:A:h:h}
TRAPZERR() {
    local code=$?
    print -u2 -- "macOS setup failed (exit $code) at ${funcfiletrace[1]}. Fix the reported error, then rerun $repo/macos/install.sh"
    return $code
}

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    print -u2 'Install Homebrew from https://brew.sh first, then rerun this script.'
    exit 1
fi
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_CURL_CONNECT_TIMEOUT=20 HOMEBREW_CURL_MAX_TIME=300
# Use the shell's XDG location for Homebrew's per-cask trust record too.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
brew tap nikitabobko/tap
brew trust --cask nikitabobko/tap/aerospace
brew bundle install --file="$repo/macos/Brewfile" --no-upgrade
# compaudit rejects group-writable parents of completion directories.
chmod go-w "$HOMEBREW_PREFIX/share"
source "$repo/macos/env.zsh"
/bin/zsh "$repo/macos/install-nnn.sh"

if [[ ! -e $HOME/.oh-my-zsh ]]; then
    git -c http.connectTimeout=20 -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=60 \
        clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
elif [[ ! -r $HOME/.oh-my-zsh/oh-my-zsh.sh ]]; then
    print -u2 'Existing ~/.oh-my-zsh is incomplete. Move it aside before retrying.'
    exit 1
fi
if [[ ! -e $HOME/.oh-my-zsh/custom/plugins/z.lua ]]; then
    git -c http.connectTimeout=20 -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=60 \
        clone --depth 1 https://github.com/skywind3000/z.lua.git "$HOME/.oh-my-zsh/custom/plugins/z.lua"
fi

export UV_HTTP_TIMEOUT=60 UV_HTTP_RETRIES=3
uv python install --default --preview-features python-install-default 3.13
uv tool install --python 3.13 python-lsp-server
# This server still imports pygls 1.x's LanguageServer API.
uv tool install --python 3.13 --with 'pygls<2' --force cmake-language-server
python_env="$XDG_DATA_HOME/nvim/python"
[[ -x $python_env/bin/python ]] || uv venv --python 3.13 "$python_env"
uv pip install --python "$python_env/bin/python" pynvim debugpy

npm install --global --fetch-retries=2 --fetch-timeout=120000 \
    'typescript@<7' typescript-language-server @vue/language-server @vue/typescript-plugin \
    @tailwindcss/language-server vscode-langservers-extracted vim-language-server \
    bash-language-server prettier pnpm

if ! rustup show active-toolchain >/dev/null 2>&1; then
    rustup default stable
fi
rustup component add rust-src rust-analyzer rustfmt clippy

# Preserve English, French and Chinese OCR without downloading every language.
tessdata="$XDG_DATA_HOME/shell/tessdata"
mkdir -p "$tessdata"
for lang in eng osd; do
    ln -sf "$HOMEBREW_PREFIX/share/tessdata/$lang.traineddata" "$tessdata/$lang.traineddata"
done
for lang in fra chi_sim chi_tra; do
    if [[ ! -s $tessdata/$lang.traineddata ]]; then
        curl --fail --location --connect-timeout 20 --max-time 120 \
            "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/4.1.0/$lang.traineddata" \
            -o "$tessdata/$lang.traineddata.part"
        mv "$tessdata/$lang.traineddata.part" "$tessdata/$lang.traineddata"
    fi
done

# Configure inverse search only when Skim has no existing editor preference.
if ! /usr/bin/defaults read net.sourceforge.skim-app.skim SKTeXEditorCommand >/dev/null 2>&1; then
    /usr/bin/defaults write net.sourceforge.skim-app.skim SKTeXEditorPreset -string ''
    /usr/bin/defaults write net.sourceforge.skim-app.skim SKTeXEditorCommand -string "$HOMEBREW_PREFIX/bin/nvim"
    /usr/bin/defaults write net.sourceforge.skim-app.skim SKTeXEditorArguments -string '--headless -c "VimtexInverseSearch %line '\''%file'\''"'
fi

/bin/zsh "$repo/macos/link-configs.sh"
/usr/bin/open -gj -a SwiftBar
nvim_error_check='+lua if vim.v.errmsg ~= "" then vim.api.nvim_err_writeln(vim.v.errmsg); vim.cmd("cquit") end'
nvim --headless '+Lazy! restore' "$nvim_error_check" +qa
nvim --headless +InstallParsers "$nvim_error_check" +qa
/bin/zsh "$repo/macos/record-installation.sh"
print 'macOS setup finished. Open a new terminal, or run: exec zsh -l'

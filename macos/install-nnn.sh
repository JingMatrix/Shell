#!/bin/zsh
# Build Nerd Font icons without modifying Homebrew's packaged nnn.
set -euo pipefail
[[ $OSTYPE == darwin* ]] || { print -u2 'This installer is for macOS only.'; exit 1; }
repo=${0:A:h:h}
source "$repo/macos/env.zsh"
version=5.3
checksum=79ee69f3ced7c0778d207df76b4d4d680636975ccda002eeb19d0917fcba3d36
workdir=$(mktemp -d "${TMPDIR:-/tmp}/nnn-build.XXXXXXXX")
trap 'rm -rf -- "$workdir"' EXIT

curl --fail --location --connect-timeout 20 --max-time 120 \
    "https://github.com/jarun/nnn/archive/refs/tags/v$version.tar.gz" \
    -o "$workdir/source.tar.gz"
printf '%s  %s\n' "$checksum" "$workdir/source.tar.gz" | shasum -a 256 -c -
tar -xzf "$workdir/source.tar.gz" -C "$workdir"
export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/ncurses/lib/pkgconfig:$HOMEBREW_PREFIX/opt/readline/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/readline/include${CPPFLAGS:+ $CPPFLAGS}"
/usr/bin/make -C "$workdir/nnn-$version" CC=/usr/bin/clang O_NERD=1 O_NORL=0 \
    LDFLAGS="-L$HOMEBREW_PREFIX/opt/readline/lib${LDFLAGS:+ $LDFLAGS}"
[[ $("$workdir/nnn-$version/nnn" -V 2>&1) == "$version" ]]

mkdir -p "$HOME/.local/bin"
if [[ -e $HOME/.local/bin/nnn || -L $HOME/.local/bin/nnn ]]; then
    backup="$XDG_STATE_HOME/shell-config/backups/$(date +%Y%m%d-%H%M%S)-$$"
    mkdir -p "$backup"
    cp -P "$HOME/.local/bin/nnn" "$backup/nnn"
    print -r -- "Backed up previous user nnn to $backup/nnn"
fi
install -m 755 "$workdir/nnn-$version/nnn" "$HOME/.local/bin/nnn.part"
mv -f "$HOME/.local/bin/nnn.part" "$HOME/.local/bin/nnn"
mkdir -p "$XDG_DATA_HOME/zsh/site-functions"
install -m 644 "$workdir/nnn-$version/misc/auto-completion/zsh/_nnn" \
    "$XDG_DATA_HOME/zsh/site-functions/_nnn"
print "Installed nnn $version with Nerd Font icons in ~/.local/bin/nnn"

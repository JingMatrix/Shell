#!/bin/zsh
set -euo pipefail
[[ $OSTYPE == darwin* ]] || { print -u2 'This installer is for macOS only.'; exit 1; }
repo=${0:A:h:h}
TRAPZERR() {
    local code=$?
    print -u2 -- "Android setup failed (exit $code) at ${funcfiletrace[1]}. Fix the reported error, then rerun $repo/macos/install-android.sh"
    return $code
}
source "$repo/macos/env.zsh"
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_CURL_CONNECT_TIMEOUT=20 HOMEBREW_CURL_MAX_TIME=300
brew bundle install --file="$repo/macos/Brewfile.android" --no-upgrade
chmod go-w "$HOMEBREW_PREFIX/share"

export ANDROID_HOME=${ANDROID_HOME:-$HOME/Library/Android/sdk}
mkdir -p "$ANDROID_HOME" "$HOME/.android"
bootstrap_sdkmanager="$HOMEBREW_PREFIX/share/android-commandlinetools/cmdline-tools/latest/bin/sdkmanager"
export JAVA_TOOL_OPTIONS='-Dsun.net.client.defaultConnectTimeout=20000 -Dsun.net.client.defaultReadTimeout=120000'
if [[ -x $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager ]]; then
    sdkmanager_bin="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
else
    sdkmanager_bin=$bootstrap_sdkmanager
fi
# A finite set of answers avoids an unbounded yes process/SIGPIPE in pipefail mode.
printf 'y\n%.0s' {1..100} | "$sdkmanager_bin" --sdk_root="$ANDROID_HOME" --licenses
packages=()
while IFS= read -r package; do
    [[ -z $package || $package == \#* ]] || packages+=("$package")
done < "$repo/macos/android-packages.txt"
"$sdkmanager_bin" --sdk_root="$ANDROID_HOME" --channel=0 "${packages[@]}"
source "$repo/macos/env.zsh"

avd_name=Android_RE_API_36
avds=$("$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" list avd -c)
if ! print -r -- "$avds" | /usr/bin/grep -Fxq "$avd_name"; then
    printf 'no\n' | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
        --name "$avd_name" --package 'system-images;android-36;google_apis;arm64-v8a' \
        --device pixel_7
fi

export UV_HTTP_TIMEOUT=60 UV_HTTP_RETRIES=3
uv tool install --python 3.13 frida-tools
uv tool install --python 3.13 objection
uv tool install --python 3.13 mitmproxy

# Keep the Android server/Gadget at exactly the installed Frida client version.
frida_version=$(frida --version)
[[ $frida_version =~ '^[0-9]+\.[0-9]+\.[0-9]+$' ]] || { print -u2 'Unexpected Frida version.'; exit 1; }
frida_dir="$XDG_DATA_HOME/android-re/frida/$frida_version"
mkdir -p "$frida_dir"
for artifact in frida-server frida-gadget; do
    if [[ $artifact == frida-gadget ]]; then
        extension=.so
    else
        extension=''
    fi
    target="$frida_dir/$artifact-android-arm64$extension"
    if [[ ! -s $target ]]; then
        curl --fail --location --connect-timeout 20 --max-time 300 \
            "https://github.com/frida/frida/releases/download/$frida_version/$artifact-$frida_version-android-arm64$extension.xz" \
            -o "$target.xz.part"
        xz --test "$target.xz.part"
        xz --decompress --stdout "$target.xz.part" > "$target.part"
        chmod 755 "$target.part"
        mv "$target.part" "$target"
        rm "$target.xz.part"
    fi
done
nvim_plugins="$XDG_CONFIG_HOME/nvim/lua/plugins.lua"
if (( $+commands[nvim] )) && [[ ${nvim_plugins:A} == $repo/nvim/plugins.lua ]]; then
    nvim --headless +InstallParsers '+lua if vim.v.errmsg ~= "" then vim.api.nvim_err_writeln(vim.v.errmsg); vim.cmd("cquit") end' +qa
fi
print "Android setup finished. SDK: $ANDROID_HOME; emulator: $avd_name"
print "Matching Frida server/Gadget: $frida_dir"
/bin/zsh "$repo/macos/record-installation.sh"

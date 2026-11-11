#!/bin/zsh
# Refresh the local tool inventory without recording credentials or host identity.
set -euo pipefail
repo=${0:A:h:h}
source "$repo/macos/env.zsh"
inventory=$(mktemp "$repo/macos/.installed-versions.XXXXXXXX")
trap 'rm -f -- "$inventory"' EXIT
{
    printf 'Checked at: %s\n\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    print 'Homebrew formulae:'
    brew list --formula --versions
    print '\nHomebrew applications:'
    brew list --cask --versions
    if [[ -x $HOME/.local/bin/nnn ]]; then
        print '\nUser-installed nnn:'
        "$HOME/.local/bin/nnn" -V 2>&1
    fi
    print '\nIsolated Python tools:'
    uv tool list
    if (( $+commands[frida] )); then
        printf '\nFrida core: %s\n' "$(frida --version)"
    fi
    print '\nAndroid SDK packages:'
    python3 - "${ANDROID_HOME:-$HOME/Library/Android/sdk}" <<'PY'
import pathlib
import sys
import xml.etree.ElementTree as ET

sdk = pathlib.Path(sys.argv[1])
rows = []
for path in sdk.glob("**/package.xml"):
    root = ET.parse(path).getroot()
    for package in root:
        if package.tag.rsplit("}", 1)[-1] != "localPackage":
            continue
        revision = next((item for item in package if item.tag.rsplit("}", 1)[-1] == "revision"), None)
        version = ".".join(item.text for item in revision) if revision is not None else "unknown"
        rows.append((package.attrib["path"], version))
for name, version in sorted(rows):
    print(f"{name} {version}")
if not rows:
    print("Not installed")
PY
} > "$inventory"
mv "$inventory" "$repo/macos/installed-versions.txt"
print 'Updated macos/installed-versions.txt'

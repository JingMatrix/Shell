# macOS development setup

This is a port of this repository's shell and Neovim configuration. A regular local
`~/.zshrc` loads Oh My Zsh, its plugins, and Powerlevel10k, then sources this
repository's `.zshrc`. On Darwin, that file selects the shared `macos/zshrc` settings;
Linux and Termux retain their original branches. `update_symbolic_links.sh` also selects the macOS linker without running
the Linux desktop, PAM, NetworkManager, or Sway installation steps.

## Install or repair

This setup was verified on Apple Silicon. The Android emulator image and Frida
device binaries selected below are ARM64.

Install [Homebrew](https://brew.sh) once, then run from this repository:

```sh
/bin/zsh macos/install.sh
exec zsh -l
```

The installer can be rerun after an interrupted download. Packages are listed in
`Brewfile`; it does not upgrade existing Homebrew packages. Existing configuration
files are moved to `~/.local/state/shell-config/backups/<timestamp>/` before linking.
The old `~/.zshrc` repository symlink is migrated to a regular file based on
`macos/zshrc.local`. Existing regular `~/.zshrc` and `~/.p10k.zsh` files are preserved
on reruns; if bringing your own startup file, source the repository's `.zshrc`
after initializing Oh My Zsh. The template records this checkout's absolute path,
so update `SHELL_CONFIG_REPO` in your local file if you move the checkout.
Go is managed by Homebrew; user-installed Go tools remain in `~/.local/go/bin`.
No credentials or Git identity are installed from the Termux provisioning script.

For the command-line Android development and reverse-engineering environment:

```sh
/bin/zsh macos/install-android.sh
exec zsh -l
```

This installs no Android Studio. `Brewfile.android` records the host tools and
`android-packages.txt` records the SDK packages. `record-installation.sh` refreshes
`installed-versions.txt` with the versions actually installed on this machine.

The manifests reproduce the tool selection and configuration, rather than an
exact snapshot of every package version. Homebrew, npm, uv, and Rust can resolve
newer releases on a fresh Mac; Neovim plugins use the committed lockfile, and
versioned Android SDK package identifiers are listed explicitly. The installed
version inventory is a reference, not an installer lockfile.

On a new Mac, install Apple's Command Line Tools if Homebrew requests them. After
the installers finish, open AeroSpace and grant Accessibility permission, then
open a new terminal. macOS permissions must be granted on each machine.

## Shell behavior

The startup order is explicit:

1. Local `~/.zshrc` changes to `$HOME` before the instant prompt, then loads the
   environment, Oh My Zsh/plugins, and Powerlevel10k. New interactive shells,
   including nested shells and new tabs, start at home.
2. Local `~/.p10k.zsh` controls prompt appearance; run `p10k configure` to customize.
3. Local `~/.zshrc` sources this checkout's `.zshrc`, which loads shared aliases,
   functions, history settings, keybindings, fzf, and highlighting from `macos/zshrc`.

The shared macOS configuration does not select a theme or initialize Oh My Zsh.
Edit the local files for machine-specific choices; edit this project for shared
behavior. New installations start with a small two-line Powerlevel10k prompt,
using the existing Hack Nerd Font, with instant prompt enabled.

An empty, regular `~/.hushlogin` file suppresses the login greeting, including the
message from `/etc/motd`, for this user. The installer creates this local marker
once and preserves it on reruns. Remove the file to show the greeting again.

| Original workflow | macOS adaptation |
| --- | --- |
| Oh My Zsh, git/pip/gradle plugins, vi editing | Retained, including the real `gradle` command instead of the plugin alias. |
| `z.lua` and `zsh-interactive-cd` | Retained; fzf provides the directory picker. |
| Syntax highlighting and completions | Homebrew packages, with the original cursor/highlighter settings. |
| Ctrl-Y / Ctrl-Z / Ctrl-F / Ctrl-H | Redo / undo / help / delete previous word. |
| Ctrl-K | Copy the command buffer with `pbcopy`, then clear it. |
| Ctrl-B Ctrl-B | Put `tmux attach \|\| tmux` into the buffer; Enter executes it. |
| `ocr [eng\|fra\|chi_sim\|chi_tra\|num] [image]` | Read a clipboard image or select a region with macOS Screenshot; copy OCR text back. |
| `qb` | Use qutebrowser's own IPC through its CLI; omit Sway workspace manipulation. |
| `ls`, `l`, Kitty links | `eza` replaces GNU-only flags/colorls; Kitty-specific helpers load only inside Kitty. |
| `nnn` deletion | Uses `/usr/bin/trash` to move items to macOS Trash, including outside Kitty. |
| User binaries, Go, Cargo, gems, pnpm | Preserve inherited PATH and add user tool paths without replacing system paths. |
| Android/Kaldi/luamake | Enabled when their SDK/project directories exist, with the native Mac Android SDK path preferred. |
| `MUTTBOX=gmail`, Neovim man pages | Retained. |

Node 24 and JDK 21 are selected through their Homebrew paths. Python 3.13 is
managed by uv; Python CLI tools and the Neovim provider/debugger have isolated
environments. Rust uses rustup. LLVM tools are appended to PATH so Apple's compiler
remains the default. Project virtual environments and versioned project tools can
still take precedence when activated.

`install-nnn.sh` builds nnn 5.3 with `O_NERD=1 O_NORL=0`, using a checksum-verified
release archive and Homebrew's ncurses/readline. The binary is installed in
`~/.local/bin/nnn`, with zsh completion in `~/.local/share/zsh/site-functions`.
Homebrew's nnn package is not needed; `gnu-sed` remains a runtime dependency.
Hack Nerd Font is already configured in Kitty. Rerun
`/bin/zsh macos/install-nnn.sh` to rebuild. Linux's nnn installation is unaffected.

JDTLS uses Homebrew's newer JDK for its own Eclipse runtime; project builds still
default to JDK 21. The CMake server is installed with `pygls<2` because it uses that
API. Neither constraint changes project dependencies.

Linux input-method, GTK, D-Bus, framebuffer and Wayland variables are omitted.
The Linux-only scripts directory is not added wholesale to the Mac PATH. Existing
iTerm2 settings are retained; select **Hack Nerd Font** in the terminal profile to
display your Airline icons.

Kitty uses the existing `terminal/kitty.conf`, linked to `~/.config/kitty/kitty.conf`.
This preserves its font, shortcuts, and 80% background opacity. A small
`kitty-macos.conf` override replaces the Linux abstract socket with a local
filesystem socket and hides the native title bar. Newly launched Kitty instances
use these settings; fully quit and reopen existing instances to apply the title
bar change reliably. Transparency also needs a restart when dynamic opacity was
disabled at startup.

## Window management

AeroSpace is installed from `nikitabobko/tap`. Its configuration is tracked in
`macos/aerospace.toml` and linked to `~/.aerospace.toml`. It starts at login and uses
tiling layout with zero gaps. Focus follows the mouse over managed windows.
New windows are moved to the visible workspace on the monitor containing the
pointer and focused there, including when the pointer is over an empty desktop.
This rule skips windows restored during AeroSpace startup. AeroSpace's native
mouse focus does not select an empty desktop until a window is opened there.
Dialogs retain AeroSpace's floating behavior. macOS native fullscreen is not used
for this layout. Existing stacked workspaces can be switched to tiles with
**Option-slash**; the default applies to newly created workspace containers.

- **Command-Return** opens a new Kitty window from any application, reusing the
  running Kitty instance. It first focuses the pointer's monitor and starts Kitty
  at `$HOME`. AeroSpace sizes it according to the current layout.
- **Option-H/J/K/L** moves focus; add Shift to move the window.
- **Option-1…9** switches workspace; add Shift to send the window there.
- **Option-0** switches to workspace **10**; **Option-Shift-0** sends the window
  there. Workspace names do not have to match the shortcut key.
- **Option-Tab** returns to the previous workspace.
- **Option-comma** selects stacked layout; **Option-slash** selects split tiles.
- **Option-F** toggles AeroSpace fullscreen on the current desktop.
- **Option-Shift-F** toggles native macOS fullscreen (a separate Space).
- **Option-Shift-Space** toggles floating/tiling.
- **Option-Shift-R** reloads the configuration.

Open AeroSpace once and grant its macOS Accessibility permission to activate
window management and global keys. If that permission is managed by your
organization, it must be enabled through your administrator. Use the AeroSpace
menu to pause window management, or run `aerospace enable off`.

SwiftBar adds a layout indicator, refreshed every second: `STACK ↔`, `TILE ↕`,
or `FLOAT`. AeroSpace's native item retains the workspace number; the new item
does not repeat it. Arrows show layout orientation. `EMPTY` means no focused
window, and `FULL` marks AeroSpace
fullscreen (separate from macOS native fullscreen). Click the indicator to inspect
the state and choose a specific layout; the active layout has a checkmark.
`WM !` means status could not be read; details are written to SwiftBar's logs.

The plugin is `macos/swiftbar/aerospace.1s.py`, linked into SwiftBar's plugin
folder (by default `~/.config/swiftbar`). AeroSpace launches SwiftBar at startup.
To disable the indicator, use SwiftBar's plugin menu. To remove it entirely, quit
SwiftBar, remove the plugin link and AeroSpace's SwiftBar startup command, then
run `brew uninstall --cask swiftbar`.

## Neovim

The existing `init.vim`, `vim-init.lua`, notes snippets, Startify, Airline, netrw,
vimtex, fugitive, surround/commentary, fzf, nnn, undo tree, and debugger mappings are
retained. The macOS plugin list is now reproducible through lazy.nvim and
`nvim/lazy-lock.json`, rather than the old directory listing in `vim.plugin`.

- Existing leader is backslash. `\pf` finds files, `\pg` searches text, `\pb` lists buffers.
- LSP mappings include `gd`, `gD`, `gK`, `gi`, `gr`, Space-rn, Space-ca, Space-f,
  Space-e, and `[d` / `]d`.
- Existing debugger mappings remain: `\dc`, `\dsv`, `\dsi`, `\dso`, `\<Enter>`, `\dg`.
- Ctrl-T opens a terminal split, Ctrl-H opens Startify, and F5 opens undo history.
- Completion keeps native Ctrl-X Ctrl-O and the existing fzf completion mappings.
- `:Lazy` manages plugins; `:InstallParsers` installs the configured syntax parsers.
- Clipboard uses macOS, undo/backup files use Neovim's private state directories,
  and both note timestamps and UltiSnips use portable Vim date formatting.

Language servers cover Python, shell, C/C++, CMake, Go, Rust, Java, Lua, Vim,
Markdown, HTML/CSS, TypeScript/JavaScript, Vue, and Tailwind. Servers only enable
when their executable is available. Debugging uses LLVM's `lldb-dap` and a dedicated
Python environment with `debugpy`, with the project environment detected separately.

## Optional applications

LaTeX remains configured for `latexmk`, now with Skim for PDF search. Install a
TeX distribution separately if you need compilation (it needs an administrator
installer and can be large): `brew install --cask basictex`. Install the TeX packages
your documents need with `tlmgr`. qutebrowser remains optional:
`brew install --cask qutebrowser`. The original Linux browser config is not installed
because it contains desktop-specific integrations.

Skim inverse search is configured for Neovim when no editor preference already
exists. Shift-Command-click in a compiled PDF jumps back to its TeX source.

Tailscale is excluded from the setup manifest because this work Mac may restrict
it. To remove the separately installed app, quit it and run
`brew uninstall --cask --zap tailscale-app`, approving system-extension removal
if macOS asks. `--zap` also removes saved Tailscale settings and state.

## Android command-line environment

The SDK is in `~/Library/Android/sdk`. It includes API 36 and API 37.0 platforms,
Build Tools 37.0.0 (`aapt2`, `apksigner`, `zipalign`), platform-tools (`adb`,
`fastboot`), sources, NDK r30 LTS, CMake 3.31.6, and the native ARM64 emulator.
`ANDROID_HOME`, SDK tool paths, and NDK compatibility variables are configured in
`env.zsh`. Host compilers keep their existing paths; the NDK compiler is selected
explicitly through the SDK or the project's `ndkVersion`.

The installer creates `Android_RE_API_36` using a Google APIs ARM64 image rather
than a Play Store image, so it supports `adb root` for native debugging. Start it:

```sh
emulator -avd Android_RE_API_36
adb devices
```

Use the project's `./gradlew` to build Android apps; its wrapper and Android
Gradle plugin determine the appropriate project tool versions. Java 21 remains
the shell default. Neovim has Kotlin, smali, XML, and CMake syntax parsers. The
optional JetBrains Kotlin language server was tested but its native launcher was
blocked by macOS security policy, so it is excluded. Enabling that component would
require resolving the block with your IT administrator; no security settings were
changed. Kotlin compilation through project Gradle wrappers is independent of LSP.

The reverse-engineering tools include:

- `jadx` / `jadx-gui`: Java/Kotlin views of DEX/APK files.
- `apktool`: resources and smali decoding/rebuilding.
- `bundletool`, `d2j-dex2jar`: Android App Bundles and DEX/JAR conversion.
- `ghidraRun`, `radare2`, `rabin2`: native binary analysis. Ghidra uses its own
  JDK 25 through shell launchers, preserving Java 21 for project builds.
- `scrcpy`: device display/control through adb.
- `frida`, `frida-ps`, `frida-trace`, `objection`: runtime exploration in isolated
  uv environments.
- `mitmproxy`, `mitmweb`, `mitmdump`: an explicitly started debugging proxy.

Matching ARM64 Frida server and Gadget binaries are kept under
`~/.local/share/android-re/frida/<frida-version>/`. After upgrading the Frida
client, rerun `install-android.sh` to fetch the corresponding device binaries.
Device-side Frida needs the matching server running on a rooted device/emulator,
or an application built with Gadget. The setup does not modify physical devices,
install trust certificates, or change the Mac's proxy settings.

The batch installer uses the still-available `sdkmanager` compatibility interface
for package manifests and license acceptance. Google's newer `android` CLI is also
installed for interactive SDK maintenance.

Verified on 2026-11-11: shell paths and Homebrew Go; an ARM64 JNI library build;
Java/DEX/APK packaging, alignment, signing and signature verification; Apktool
decode/rebuild; JADX decompilation; DEX-to-JAR conversion; Ghidra headless ARM64
analysis; hardware-accelerated emulator boot; adb app install/launch; and Frida
17.26.2 attaching to the test app and calling its JNI function. The test app and
Frida server were removed, and the emulator was shut down afterward.

For rollback, replace each installed symlink with its saved original from the
backup directory and open a new terminal. Configurations that did not previously
exist have no backup. This does not uninstall tools or remove project data.

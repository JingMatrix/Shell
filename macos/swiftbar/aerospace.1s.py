#!/usr/bin/python3
# <xbar.title>AeroSpace layout</xbar.title>
# <xbar.desc>Focused workspace, layout, and AeroSpace fullscreen state.</xbar.desc>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>

import pathlib
import subprocess
import sys


def query(cli, *args):
    return subprocess.run(
        [str(cli), *args], check=True, capture_output=True, text=True, timeout=3
    ).stdout.strip()


def render(cli):
    workspace = query(cli, "list-workspaces", "--focused")
    # Workspace names are display text, never SwiftBar parameters or commands.
    if not workspace or any(c in workspace for c in "|\r\n"):
        raise ValueError("Invalid focused workspace")
    try:
        window = query(
            cli, "list-windows", "--focused", "--format",
            "%{window-layout} %{window-is-fullscreen}",
        )
    except subprocess.CalledProcessError:
        # An empty workspace has no focused window. Other failures stay errors.
        if query(cli, "list-windows", "--workspace", workspace, "--count") != "0":
            raise
        window = ""

    layouts = {
        "h_tiles": "TILE ↔",
        "v_tiles": "TILE ↕",
        "h_accordion": "STACK ↔",
        "v_accordion": "STACK ↕",
        "floating": "FLOAT",
    }
    layout, fullscreen = "", "false"
    if window:
        layout, fullscreen = window.split()
        if layout not in layouts or fullscreen not in ("true", "false"):
            raise ValueError("Unrecognized AeroSpace window state")
    label = layouts.get(layout, "EMPTY")
    suffix = " · FULL" if fullscreen == "true" else ""
    # AeroSpace already displays the workspace number in its own menu item.
    lines = [f"{label}{suffix}", "---", f"Workspace {workspace}"]
    lines += [f"Layout: {label}", f"AeroSpace fullscreen: {fullscreen}", "---"]
    for title, target in (
        ("Tiles: side by side", "h_tiles"),
        ("Tiles: top and bottom", "v_tiles"),
        ("Stacked: navigate left/right", "h_accordion"),
        ("Stacked: navigate up/down", "v_accordion"),
        ("Floating", "floating"),
    ):
        checked = str(layout == target).lower()
        lines.append(
            f"{title} | bash={cli} param1=layout param2={target} "
            f"terminal=false refresh=true checked={checked}"
        )
    lines += ["---", "Refresh | refresh=true"]
    return "\n".join(lines)


def main():
    cli = next((path for path in (
        pathlib.Path("/opt/homebrew/bin/aerospace"),
        pathlib.Path("/usr/local/bin/aerospace"),
    ) if path.is_file()), None)
    try:
        if cli is None:
            raise FileNotFoundError("AeroSpace CLI is not installed")
        print(render(cli))
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        # Keep a visible degraded state and expose details through SwiftBar logs.
        print("WM !\n---\nAeroSpace status unavailable\nRefresh | refresh=true")
        print(f"AeroSpace indicator: {error}", file=sys.stderr)


if __name__ == "__main__":
    main()

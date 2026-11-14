#! /bin/sh

# Print the active xkb layout for waybar.
#
# The built-in sway/language module cannot blank its label: once it has shown a
# non-empty value it keeps that text, so switching back to fr(vim) left "fr" on
# screen. fr(vim) has no short name because the custom variant is not in the xkb
# registry (/usr/share/X11/xkb/rules/evdev.xml), which is intentional - it should
# render blank. A custom module is hidden when its output is empty, so it can.

layout=$(swaymsg -t get_inputs -r 2>/dev/null |
	grep -m1 '"xkb_active_layout_name"' |
	sed 's/.*: *"\(.*\)".*/\1/')

case "$layout" in
"French") printf '%s' "fr" ;;
*) printf '' ;; # fr(vim) and anything else: blank
esac

#! /bin/sh

# Brightness for an external monitor, over DDC/CI.
#
# matrix.xyz drives a DisplayPort panel, so /sys/class/backlight is empty and
# neither brightnessctl nor waybar's backlight module can see anything. (Worse,
# brightnessctl with no backlight device falls through to the first LED device
# and dims the Num Lock LED.) External panels expose brightness as VCP feature
# 0x10 over the monitor's I2C/DDC channel instead.
#
# Requires: ddcutil, the i2c-dev kernel module, and membership of the i2c group.
# Until those exist every path below exits 0 with no output, so waybar simply
# hides the module rather than erroring.
#
# Usage:
#   brightness.sh          print current brightness as waybar JSON
#   brightness.sh + 5      raise by 5, then refresh waybar
#   brightness.sh - 5      lower by 5, then refresh waybar

command -v ddcutil >/dev/null 2>&1 || exit 0

# ddcutil detect costs ~1s; cache the bus number for the life of the session.
cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-ddc-bus"
if [ -s "$cache" ]; then
	bus=$(cat "$cache")
else
	bus=$(ddcutil detect --terse 2>/dev/null |
		sed -n 's|^ *I2C bus: */dev/i2c-\([0-9]*\).*|\1|p' | head -1)
	[ -n "$bus" ] && printf '%s' "$bus" >"$cache"
fi
[ -n "$bus" ] || exit 0

case "$1" in
+ | -)
	ddcutil --bus "$bus" setvcp 10 "$1" "${2:-5}" >/dev/null 2>&1
	pkill -RTMIN+9 waybar 2>/dev/null
	exit 0
	;;
esac

# getvcp --terse prints: VCP 10 C <current> <max>
current=$(ddcutil --bus "$bus" getvcp 10 --terse 2>/dev/null | awk '{print $4}')
case "$current" in
'' | *[!0-9]*) exit 0 ;;
esac

printf '{"percentage":%s,"tooltip":"Monitor brightness %s%% (DDC/CI, bus %s)"}\n' \
	"$current" "$current" "$bus"

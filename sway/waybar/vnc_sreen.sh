#! /bin/zsh

if swaymsg -t get_outputs | grep '"name": "HEADLESS-1"'; then
	echo "Output HEADLESS-1 exists"
else
	notify-send "No headless ouput" "Creating a new one"
	swaymsg create_output
fi

if pgrep wayvnc; then
	echo "Wayvnc already runing"
else
	pushd /tmp
	nohup wayvnc -o HEADLESS-1 &
	popd
fi

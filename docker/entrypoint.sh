#!/bin/sh
# Selects a GDK backend based on what the container was given:
#   - a Wayland socket (WAYLAND_DISPLAY + mounted XDG_RUNTIME_DIR) -> wayland
#   - an X11 socket (DISPLAY + mounted /tmp/.X11-unix)             -> x11
#   - nothing                                                      -> headless Xvfb
set -e

if [ -n "$WAYLAND_DISPLAY" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$WAYLAND_DISPLAY" ]; then
	export GDK_BACKEND="${GDK_BACKEND:-wayland}"
elif [ -n "$DISPLAY" ]; then
	export GDK_BACKEND="${GDK_BACKEND:-x11}"
else
	export DISPLAY="${XVFB_DISPLAY:-:99}"
	export GDK_BACKEND=x11
	# no session bus when headless: keep the a11y bridge from spamming warnings
	export NO_AT_BRIDGE=1 GTK_A11Y=none
	Xvfb "$DISPLAY" -screen 0 "${XVFB_WHD:-1024x768x24}" -nolisten tcp &
	i=0
	while [ ! -S "/tmp/.X11-unix/X${DISPLAY#:}" ]; do
		i=$((i + 1))
		if [ "$i" -ge 50 ]; then
			echo "Xvfb failed to start" >&2
			exit 1
		fi
		sleep 0.1
	done
fi

exec "$@"

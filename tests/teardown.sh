#!/bin/sh
if [ -n "$KEEP_STACK" ]; then
	exit 0
fi
docker ps -aq --filter label=docker-gtk-test=1 | xargs docker rm -f >/dev/null 2>&1 || true

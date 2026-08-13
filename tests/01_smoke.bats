#!/usr/bin/env bats
load helper.sh

teardown() {
	docker ps -aq --filter label="$TEST_LABEL=1" | xargs docker rm -f >/dev/null 2>&1 || true
}

@test "image ships both demo binaries and the entrypoint" {
	run docker run --rm --entrypoint sh "$IMAGE" -c 'command -v demo-gtk3 demo-gtk4 Xvfb'
	[ "$status" -eq 0 ]
}

@test "gtk4 demo renders a window headlessly under Xvfb" {
	cid=$(run_demo)
	wait_for_window "$cid" "Docker GTK"
	[ "$(docker inspect -f '{{.State.Status}}' "$cid")" = "running" ]
	run docker logs "$cid"
	[ "$status" -eq 0 ]
	! echo "$output" | grep -qiE 'gtk-(critical|error)|cannot open display|Xvfb failed'
}

@test "gtk3 demo renders a window headlessly under Xvfb" {
	cid=$(run_demo demo-gtk3)
	wait_for_window "$cid" "Docker GTK"
	[ "$(docker inspect -f '{{.State.Status}}' "$cid")" = "running" ]
	run docker logs "$cid"
	[ "$status" -eq 0 ]
	! echo "$output" | grep -qiE 'gtk-(critical|error)|cannot open display|Xvfb failed'
}

# Shared helpers for the bats e2e suite. POSIX sh.
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "${BATS_TEST_DIRNAME:-${BATS_SUITE_DIRNAME:-$(dirname -- "$0")}}/.." && pwd)}"
IMAGE="${IMAGE:-${DOCKER_REGISTRY:-registry.gitlab.com/bitspur/rock8s/docker-gtk}/docker-gtk:${DOCKER_TAG:-latest}}"
TEST_LABEL=docker-gtk-test

run_demo() {
	docker run -d --label "$TEST_LABEL=1" "$IMAGE" "$@"
}

# wait_for_window <container> <title> [timeout-seconds]
# Polls the container's Xvfb display until a window with the given title maps.
wait_for_window() {
	i=0
	while [ "$i" -lt "$((${3:-15} * 2))" ]; do
		if docker exec -e DISPLAY=:99 "$1" xwininfo -root -tree 2>/dev/null | grep -q "\"$2\""; then
			return 0
		fi
		i=$((i + 1))
		sleep 0.5
	done
	echo "window \"$2\" never mapped in container $1" >&2
	return 1
}

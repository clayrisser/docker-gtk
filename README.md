# docker-gtk

Run GTK GUI apps with docker

![](assets/docker-gtk.png)

The image is based on `debian:trixie-slim` and ships both the GTK3 and GTK4
runtimes, two small demo apps (`demo-gtk3` and `demo-gtk4`, each rendering the
cat above), and Xvfb for headless use. Use it directly to try things out, or
as a base image for containerizing your own GTK app.

## Setup

```sh
git clone git@gitlab.com:bitspur/rock8s/docker-gtk.git
cd docker-gtk
make prepare   # once per machine: installs asdf-managed tools (bats, shfmt)
make           # builds the image with docker buildx bake
```

## Run

```sh
make run
```

The container's entrypoint picks a GDK backend from whatever display you hand
it, and `make run` forwards the right socket automatically:

| you have                | forwarded into the container              | backend  |
| ----------------------- | ----------------------------------------- | -------- |
| Wayland compositor      | `$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY` socket | wayland  |
| X11 server              | `/tmp/.X11-unix` socket + `DISPLAY`        | x11      |
| nothing (CI, servers)   | nothing — Xvfb starts inside the container | x11 (virtual) |

### X11 notes

The X server must allow connections from the container. The quick (loose) way:

```sh
xhost +local:
```

### Wayland notes

The Wayland socket is forwarded read-write into `/tmp/xdg-runtime/` inside the
container and `WAYLAND_DISPLAY` is passed through. No xhost equivalent is
needed; access control is the socket's file permissions.

### macOS notes

There is no socket to mount on macOS. Install [XQuartz](https://www.xquartz.org),
enable "Allow connections from network clients" in its settings, then:

```sh
xhost +localhost
docker run -it --rm -e DISPLAY=host.docker.internal:0 \
  registry.gitlab.com/bitspur/rock8s/docker-gtk/docker-gtk:latest
```

### Headless

With no `DISPLAY` or `WAYLAND_DISPLAY` set, the entrypoint starts Xvfb on `:99`
inside the container and the app renders to it. This is how the smoke tests
work, and it's the mode to use in CI.

## Test

```sh
make test/e2e
```

Runs a bats smoke suite that builds the image, starts each demo headlessly,
and asserts a window titled "Docker GTK" actually maps on the container's
Xvfb display (via `xwininfo`) with no GTK errors in the logs.

Headless verification covers: the app starts, connects to an X display, and
maps its window. What it can't cover: real input, compositor integration, and
whether pixels look right on your screen — for that, `make run` with a real
X11 or Wayland session.

## Image

Built with `docker buildx bake` (see `docker/docker-bake.hcl`):

```
registry.gitlab.com/bitspur/rock8s/docker-gtk/docker-gtk:latest
registry.gitlab.com/bitspur/rock8s/docker-gtk/docker-gtk:<git-commit>
```

To containerize your own GTK app, start from this image, copy your binary in,
and keep the entrypoint:

```dockerfile
FROM registry.gitlab.com/bitspur/rock8s/docker-gtk/docker-gtk:latest
COPY my-app /usr/local/bin/my-app
CMD ["my-app"]
```

FROM debian:trixie-slim AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libgtk-3-dev \
        libgtk-4-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY src/demo-gtk3.c src/demo-gtk4.c ./
RUN gcc $(pkg-config --cflags gtk+-3.0) -o demo-gtk3 demo-gtk3.c $(pkg-config --libs gtk+-3.0) && \
    gcc $(pkg-config --cflags gtk4) -o demo-gtk4 demo-gtk4.c $(pkg-config --libs gtk4)

FROM debian:trixie-slim

LABEL org.opencontainers.image.title="docker-gtk" \
      org.opencontainers.image.description="Run GTK GUI apps with docker" \
      org.opencontainers.image.source="https://gitlab.com/bitspur/rock8s/docker-gtk"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        adwaita-icon-theme \
        dbus \
        fonts-dejavu-core \
        libgtk-3-0t64 \
        libgtk-4-1 \
        x11-utils \
        xauth \
        xvfb && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --user-group default && \
    mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

COPY --from=build /build/demo-gtk3 /build/demo-gtk4 /usr/local/bin/
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY src/cat.jpg /app/cat.jpg

USER default
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["demo-gtk4"]

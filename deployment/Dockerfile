############################################################
# Dockerfile to run Docker GTK
# Based on Alpine
############################################################

FROM alpine:3.5

MAINTAINER Jam Risser (jamrizzi)

WORKDIR /app/

RUN apk --no-cache add \
        dbus \
        gtk+3.0 \
        xauth \
        xhost && \
    apk add --no-cache --virtual build-deps \
        build-base \
        gtk+3.0-dev \
        pkgconfig

RUN mkdir -p /etc/sudoers.d/ && \
    adduser -D default && \
    chgrp -R default /usr/local && \
    find /usr/local -type d | xargs chmod g+w && \
    echo "default ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/default && \
    chmod 0440 /etc/sudoers.d/default

ADD ./* /app/.tmp/
RUN cd /app/.tmp/ && make src/main && \
    apk del build-deps && \
    mv /app/.tmp/main /app/main && \
    mv /app/.tmp/cat.jpg /app/cat.jpg && \
    rm -rf /app/.tmp/

USER default

CMD /app/main

FROM haproxy:lts

USER root

# Install required software
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            socat \
            xz-utils; \
        apt-get dist-clean

# Install s6-overlay
ARG S6_OVERLAY_VERSION=3.2.1.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /usr/src/
ARG S6_OVERLAY_ARCH=x86_64
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /usr/src/
RUN set -eux; \
        tar -C / -Jxpf /usr/src/s6-overlay-noarch.tar.xz; \
        tar -C / -Jxpf /usr/src/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz

# Configure
COPY s6-rc.d/ /etc/s6-overlay/s6-rc.d/
COPY --chmod=755 sbin/ /usr/local/sbin/
STOPSIGNAL SIGTERM
ENTRYPOINT ["/init"]

USER haproxy

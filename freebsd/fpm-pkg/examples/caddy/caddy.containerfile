ARG FREEBSD_VERSION=15.0
FROM ghcr.io/freebsd/freebsd-runtime:$FREEBSD_VERSION

RUN set -eux; \
        pkg bootstrap -y; \
        \
        # disable FreeBSD-base repo
        sed -i '' 's/enabled: yes/enabled: no/' /usr/local/etc/pkg/repos/base.conf; \
        # use the latest packages
        echo 'FreeBSD-ports: { url: "pkg+https://pkg.FreeBSD.org/${ABI}/latest" }' > /usr/local/etc/pkg/repos/FreeBSD.conf; \
        \
        pkg install -y \
            caddy \
        ; \
        # cleanup to reduce image size
        pkg clean -ay; \
        rm -rf /var/db/pkg/repos

ENV XDG_CONFIG_HOME=/var/db/caddy/config \
    XDG_DATA_HOME=/var/db/caddy/data

EXPOSE 80/tcp 443/tcp 443/udp
CMD ["caddy", "run", "--config", "/usr/local/etc/caddy/Caddyfile"]

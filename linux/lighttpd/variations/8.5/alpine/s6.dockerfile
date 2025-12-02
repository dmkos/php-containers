ARG PHP_VERSION LIGHTTPD_VERSION
FROM dmkos/php:${PHP_VERSION}-lighttpd-${LIGHTTPD_VERSION}-alpine

# Switch from `www-data` set in base image
USER root

# Install php-fpm-healthcheck and required packages
ADD --chmod=755 https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck /usr/local/bin/
RUN set -eux; \
        apk add --no-cache fcgi

# Install s6-overlay
ARG S6_OVERLAY_VERSION
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /usr/src/
ARG S6_OVERLAY_ARCH=x86_64
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /usr/src/
RUN set -eux; \
        tar -C / -Jxpf /usr/src/s6-overlay-noarch.tar.xz; \
        tar -C / -Jxpf /usr/src/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz

STOPSIGNAL SIGTERM
ENTRYPOINT ["/init"]

# Configure
COPY s6-rc.d/ /etc/s6-overlay/s6-rc.d/
COPY s6.conf.d/*.conf /etc/lighttpd/conf.d/
RUN set -eux; \
        # fix permissions
        chmod 755 /etc/s6-overlay/s6-rc.d/lighttpd/data/check; \
        chmod 755 /etc/s6-overlay/s6-rc.d/php-fpm/data/check; \
        # PHP
        # php-fpm user defined in environment variable
        sed -i 's#;user = www-data#user = ${WWW_USER}#' /usr/local/etc/php-fpm.d/www.conf; \
        sed -i 's#;group = www-data#group = ${WWW_USER}#' /usr/local/etc/php-fpm.d/www.conf; \
        # parametrize socket
        sed -i 's#/tmp/www.sock-0#${FCGI_CONNECT}#' /usr/local/etc/php-fpm.d/zz-docker.conf; \
        # allow web-server to interact with socket
        echo 'listen.owner = ${WWW_USER}' >> /usr/local/etc/php-fpm.d/zz-docker.conf; \
        # php-fpm status page
        echo 'pm.status_path = /status' >> /usr/local/etc/php-fpm.d/zz-docker.conf; \
        # Lighttpd
        # parametrize socket
        sed -i 's#"/tmp/www.sock"#env.FCGI_CONNECT#' /etc/lighttpd/conf.d/500-fastcgi.conf; \
        # remove php-fpm start settings
        sed -i '27,29d' /etc/lighttpd/conf.d/500-fastcgi.conf

ENV WWW_USER=www-data \
    LIGHTTPD_MAX_FDS=1024 \
    FCGI_CONNECT=/tmp/www.sock

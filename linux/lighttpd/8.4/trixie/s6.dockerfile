ARG PHP_VERSION LIGHTTPD_VERSION
FROM dmkos/php:${PHP_VERSION}-lighttpd-${LIGHTTPD_VERSION}-trixie

# Switch from `www-data` set in base image
USER root

# Install php-fpm-healthcheck and required packages
ADD --chmod=755 https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck /usr/local/bin/
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends libfcgi-bin; \
        apt-get dist-clean

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

# PHP
RUN set -eux; \
        mkdir -p /etc/s6-overlay/s6-rc.d/php-fpm/dependencies.d; \
        cd /etc/s6-overlay/s6-rc.d/php-fpm; \
        touch dependencies.d/base; \
        \
        mkdir data; \
        { \
            echo '#!/command/with-contenv sh'; \
            echo 'php-fpm-healthcheck'; \
        } > data/check; \
        chmod +x data/check; \
        \
        echo '3' > notification-fd; \
        echo 'longrun' > type; \
        echo 'SIGQUIT' > down-signal; \
        \
        { \
            echo '#!/command/execlineb -P'; \
            echo 'with-contenv'; \
            echo 's6-notifyoncheck -d'; \
            echo '/usr/local/sbin/php-fpm'; \
        } > run; \
        chmod +x run; \
        \
        mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d; \
        touch /etc/s6-overlay/s6-rc.d/user/contents.d/php-fpm; \
        \
        # php-fpm user defined in environment variable
        sed -i 's#;user = www-data#user = ${WWW_USER}#' /usr/local/etc/php-fpm.d/www.conf; \
        sed -i 's#;group = www-data#group = ${WWW_USER}#' /usr/local/etc/php-fpm.d/www.conf; \
        # remove suffix from socket filename
        sed -i 's#/tmp/www.sock-0#${FCGI_CONNECT}#' /usr/local/etc/php-fpm.d/zz-docker.conf; \
        # allow web-server to interact with socket
        echo 'listen.owner = ${WWW_USER}' >> /usr/local/etc/php-fpm.d/zz-docker.conf; \
        # php-fpm status page
        echo 'pm.status_path = /status' >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Lighttpd
COPY s6/*.conf /etc/lighttpd/conf.d/
RUN set -eux; \
        mkdir -p /etc/s6-overlay/s6-rc.d/lighttpd/dependencies.d/; \
        cd /etc/s6-overlay/s6-rc.d/lighttpd; \
        touch dependencies.d/php-fpm; \
        \
        mkdir data; \
        { \
            echo '#!/command/with-contenv sh'; \
            echo 'curl -fs http://127.0.0.1:${LIGHTTPD_PORT}/_webserver-status?json && echo'; \
        } > data/check; \
        chmod +x data/check; \
        \
        echo '4' > notification-fd; \
        echo 'longrun' > type; \
        echo 'SIGINT' > down-signal; \
        \
        { \
            echo '#!/command/execlineb -P'; \
            echo 'with-contenv'; \
            echo 's6-notifyoncheck'; \
            echo '/usr/local/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf'; \
        } > run; \
        chmod +x run; \
        \
        touch /etc/s6-overlay/s6-rc.d/user/contents.d/lighttpd; \
        # parametrize socket
        sed -i 's#"/tmp/www.sock"#env.FCGI_CONNECT#' /etc/lighttpd/conf.d/500-fastcgi.conf; \
        # remove php-fpm start settings
        sed -i '27,29d' /etc/lighttpd/conf.d/500-fastcgi.conf

ENV WWW_USER=www-data
ENV LIGHTTPD_MAX_FDS=1024
ENV FCGI_CONNECT=/tmp/www.sock

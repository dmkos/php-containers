ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-fpm-trixie

# Copy sources
ARG LIGHTTPD_VERSION LIGHTTPD_SHA256
COPY src/lighttpd-${LIGHTTPD_VERSION}.tar.xz /usr/src/lighttpd.tar.xz
    
# Compile
RUN set -eux; \
    # Check sources
    echo "$LIGHTTPD_SHA256 /usr/src/lighttpd.tar.xz" | sha256sum -c -; \
    # Install build tools
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        automake \
        libbrotli-dev \
        libpcre2-dev \
        libssl-dev \
        libtool \
        libzstd-dev \
        zlib1g-dev \
    ; \
    # Extract and compile
    tar xJf /usr/src/lighttpd.tar.xz -C /usr/src; \
    cd /usr/src/lighttpd-${LIGHTTPD_VERSION}; \
    ./autogen.sh; \
    ./configure -C \
        --with-brotli \
        --with-openssl \
        --with-zstd \
    ; \
    make -j "$(nproc)"; \
    make check; \
    make install; \
    find /usr/local/lib \
        -type f \
        -name '*.so' \
        -exec sh -euxc ' \
            strip --strip-all "$@" || : \
        ' -- '{}' + \
    ; \
    strip --strip-all /usr/local/sbin/lighttpd; \
    strip --strip-all /usr/local/sbin/lighttpd-angel; \
    # smoke test
    lighttpd -v; \
    # pre-configure
    mkdir -p /etc/lighttpd/conf.d /usr/local/etc/lighttpd/conf.d; \
    cp doc/config/conf.d/mime.conf /etc/lighttpd/conf.d/001-mime.conf; \
    # cleanup
    make clean; \
    cd /; \
    rm -rf /usr/src/lighttpd-${LIGHTTPD_VERSION}; \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get dist-clean

# install composer from Composer's official Docker image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN set -eux; \
    # prevent Debian's Lighttpd packages from being installed
    { \
        echo 'Package: lighttpd*'; \
        echo 'Pin: release *'; \
        echo 'Pin-Priority: -1'; \
    } > /etc/apt/preferences.d/no-debian-lighttpd; \
    # install unzip for composer
    apt-get update; \
    apt-get install -y --no-install-recommends unzip; \
    apt-get dist-clean; \
    # composer working directory
    mkdir /var/www/.composer; \
    chown www-data:www-data /var/www/.composer

# Configure
COPY lighttpd.conf /etc/lighttpd/
COPY conf.d/*.conf /etc/lighttpd/conf.d/
COPY --chmod=755 variations/8.5/trixie/healthcheck /usr/local/bin/

RUN set -eux; \
    # disable PHP access log
    sed -i -r 's#^access.log = /proc/self/fd/2$#;access.log = /proc/self/fd/2#g' /usr/local/etc/php-fpm.d/docker.conf; \
    # avoid warning about user and group
    sed -i -r 's#^user = www-data$#;user = www-data#g' /usr/local/etc/php-fpm.d/www.conf; \
    sed -i -r 's#^group = www-data$#;group = www-data#g' /usr/local/etc/php-fpm.d/www.conf; \
    # listen socket
    sed -i -r 's#^listen = 9000$#listen = /tmp/www.sock-0#g' /usr/local/etc/php-fpm.d/zz-docker.conf

ENV LIGHTTPD_PORT=9000 \
    LIGHTTPD_DOCUMENT_ROOT=/var/www/html \
    HEALTHCHECK_PATH="/_webserver-status?auto"

HEALTHCHECK --interval=1m --timeout=5s --start-period=30s CMD healthcheck

STOPSIGNAL SIGINT

USER www-data
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

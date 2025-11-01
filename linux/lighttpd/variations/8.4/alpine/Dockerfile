ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine

# Fetch sources
ARG LIGHTTPD_VERSION LIGHTTPD_SHA256
RUN set -eux; \
    cd /usr/src; \
    curl -s -o lighttpd.tar.xz https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-${LIGHTTPD_VERSION}.tar.xz; \
    echo "$LIGHTTPD_SHA256 lighttpd.tar.xz" | sha256sum -c -
    
# Compile
RUN set -eux; \
    # Install build tools
    apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        brotli-dev \
        libtool \
        openssl-dev \
        pcre2-dev \
        pkgconf \
        zstd-dev \
        zlib-dev \
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
        -maxdepth 1 \
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
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache $runDeps; \
    \
    apk del --no-network .build-deps

# install composer from Composer's official Docker image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN set -eux; \
    # install unzip for composer
    apk add --no-cache unzip; \
    # composer working directory
    mkdir /var/www/.composer; \
    chown www-data:www-data /var/www/.composer

# Configure
COPY lighttpd.conf /etc/lighttpd/
COPY conf.d/*.conf /etc/lighttpd/conf.d/
COPY --chmod=755 healthcheck /usr/local/bin/

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

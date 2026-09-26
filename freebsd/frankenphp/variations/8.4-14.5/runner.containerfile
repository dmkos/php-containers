# Build stage
# -----------
#
# Extend builder image by installing PHP extensions and their dependencies.

ARG FRANKENPHP_VERSION PHP_VERSION FREEBSD_VERSION
FROM ghcr.io/dmkos/php-freebsd:frankenphp-${FRANKENPHP_VERSION}-builder-php${PHP_VERSION}-freebsd${FREEBSD_VERSION} AS builder

# Install dependencies
RUN set -eux; \
        pkg install -y \
            databases/postgresql17-client \
            devel/icu \
            graphics/libavif \
            graphics/png \
            graphics/webp \
            print/freetype2 \
            x11/libXpm \
        ; \
        # cleanup to reduce image size
        pkg clean -ay; \
        rm -rf /var/db/pkg/repos

# Build and install additional PHP extensions
RUN set -eux; \
        podman-php-source extract; \
        podman-php-ext-configure gd --with-webp --with-jpeg --with-xpm --with-freetype --with-avif; \
        podman-php-ext-install -j"$(nproc)" \
            bcmath \
            bz2 \
            gd \
            intl \
            pcntl \
            pdo_mysql \
            pdo_pgsql \
            pgsql; \
        pecl install \
            # https://pecl.php.net/package/uploadprogress
            uploadprogress-2.0.2; \
        podman-php-ext-enable uploadprogress; \
        rm -rf /tmp/pear; \
        podman-php-source delete; \
        # smoke test
        php -m | grep -e gd -e intl -e pgsql

# Composer's official Docker image
FROM --platform=linux/amd64 docker.io/library/composer:2 AS composer


# End-user stage
# --------------
#
# Create "runner" rootless image by copy builded PHP.
# All runtime dependencies should be installed again
# as we using minimal FreeBSD image.

FROM ghcr.io/freebsd/freebsd-runtime:$FREEBSD_VERSION

# Install dependencies
RUN set -eux; \
        pkg bootstrap -y; \
        \
        # use the latest packages
        mkdir -p /usr/local/etc/pkg/repos; \
        echo 'FreeBSD: { url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest" }' > /usr/local/etc/pkg/repos/FreeBSD.conf; \
        \
        pkg install -y \
            # basic
            brotli \
            capstone \
            curl \
            devel/oniguruma \
            libargon2 \
            libedit \
            libiconv \
            libsodium \
            libxml2 \
            sqlite3 \
            # additional
            databases/postgresql17-client \
            devel/icu \
            graphics/libavif \
            graphics/png \
            graphics/webp \
            print/freetype2 \
            x11/libXpm \
            # composer
            unzip \
        ; \
        # cleanup to reduce image size
        pkg clean -ay; \
        rm -rf /var/db/pkg/repos

# Copy build
COPY --from=builder --chmod=755 \
        /usr/local/bin/frankenphp \
        /usr/local/bin/pear \
        /usr/local/bin/peardev \
        /usr/local/bin/pecl \
        /usr/local/bin/phar.phar \
        /usr/local/bin/php \
        /usr/local/bin/php-cgi \
        /usr/local/bin/php-config \
        /usr/local/bin/phpdbg \
        /usr/local/bin/phpize \
        /usr/local/bin/
COPY --from=builder /usr/local/etc/frankenphp/ /usr/local/etc/frankenphp/
COPY --from=builder /usr/local/etc/php/ /usr/local/etc/php/
COPY --from=builder --chmod=644 /usr/local/etc/pear.conf /usr/local/etc/
COPY --from=builder /usr/local/include/php/ /usr/local/include/php/
COPY --from=builder /usr/local/lib/php/ /usr/local/lib/php/
COPY --from=builder --chmod=755 /usr/local/lib/libphp.so /usr/local/lib/libwatcher-c.so /usr/local/lib/
COPY --from=builder /usr/local/share/pear/ /usr/local/share/pear/
COPY --from=builder /usr/local/www/app/public/index.php /usr/local/www/app/public/

# Install composer from image
COPY --from=composer /usr/bin/composer /usr/local/bin/

# Copy sysutils
COPY --from=builder /usr/sbin/chown /usr/sbin/

COPY --chmod=755 bin/podman-php-entrypoint /usr/local/bin/
COPY --chmod=755 sbin/podman-php-fix-permissions /usr/local/sbin/

ARG PHP_VERSION
ENV GODEBUG="cgocheck=0" \
    XDG_CONFIG_HOME=/var/db/frankenphp/config \
    XDG_DATA_HOME=/var/db/frankenphp/data \
    PHP_VERSION=$PHP_VERSION \
    PHP_INI_DIR=/usr/local/etc/php

# Configure
RUN set -eux; \
        podman-php-fix-permissions; \
        cd /usr/local/bin; \
        ln -s phar.phar phar; \
        chmod -h 755 phar; \
        mkdir -p $XDG_CONFIG_HOME; \
        mkdir -p $XDG_DATA_HOME; \
        # smoke test
        php --version && frankenphp version; \
        # Run as non-root user
        chown -R www:www $PHP_INI_DIR; \
        chown -R www:www /usr/local/etc/frankenphp; \
        chown -R www:www /usr/local/www/app; \
        chown -R www:www /var/db/frankenphp; \
        # Custom ports, should be redirected
        sed -i '' 's/{$CADDY_GLOBAL_OPTIONS}/http_port 10080\n        https_port 10443\n        {$CADDY_GLOBAL_OPTIONS}/' /usr/local/etc/frankenphp/Caddyfile

EXPOSE 10080/tcp 10443/tcp 10443/udp

ENTRYPOINT ["podman-php-entrypoint"]
WORKDIR /usr/local/www/app
CMD ["--config", "/usr/local/etc/frankenphp/Caddyfile"]
USER www

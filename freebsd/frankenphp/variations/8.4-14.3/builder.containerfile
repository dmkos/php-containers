ARG FREEBSD_VERSION
FROM ghcr.io/freebsd/freebsd-runtime:$FREEBSD_VERSION

# Base OS, including `make`, complier, linker and so on
ARG FREEBSD_VERSION
RUN set -eux; \
        cd /; \
        fetch https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz; \
        # ignore permission warnings during extraction
        tar xfm base.txz -C / --keep-old-files --exclude=rescue || true; \
        rm base.txz

# Install software
RUN set -eux; \
        pkg bootstrap -y; \
        \
        # use the latest packages
        mkdir -p /usr/local/etc/pkg/repos; \
        echo 'FreeBSD: { url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest" }' > /usr/local/etc/pkg/repos/FreeBSD.conf; \
        \
        pkg install -y \
            # Build tools
            autoconf \
            automake \
            getopt \
            lang/go \
            pkgconf \
            re2c \
            # Runtime dependencies
            brotli \
            capstone \
            curl \
            devel/oniguruma \
            libargon2 \
            libedit \
            libiconv \
            libsodium \
            libxml2 \
            sqlite3; \
        # cleanup to reduce image size
        pkg clean -ay; \
        rm -rf /var/db/pkg/repos

# Fetch sources
ARG PHP_VERSION PHP_SHA256 FRANKENPHP_VERSION WATCHER_VERSION
ENV PHP_VERSION=$PHP_VERSION \
    PHP_SHA256=$PHP_SHA256
RUN set -eux; \
        fetch -o /usr/src/php.tar.xz https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz; \
        sha256 -c $PHP_SHA256 /usr/src/php.tar.xz; \
        # For GitHub sources digests are not available
        fetch -o /usr/src/frankenphp.tar.gz https://github.com/php/frankenphp/archive/refs/tags/v${FRANKENPHP_VERSION}.tar.gz; \
        fetch -o /usr/src/watcher.tar.gz https://github.com/e-dant/watcher/archive/refs/tags/${WATCHER_VERSION}.tar.gz

COPY --chmod=755 bin/podman-php-source bin/podman-php-ext-* /usr/local/bin/

# PHP build options for FreeBSD
ENV PHP_CFLAGS="-O2 -pipe -fstack-protector-strong -isystem /usr/local/include -fno-strict-aliasing" \
    PHP_LDFLAGS="-L/usr/lib -lcrypto -lssl" \
    PHP_CXXFLAGS="$PHP_CFLAGS -isystem /usr/local/include" \
    PHP_OPENSSL_CFLAGS="-I/usr/include" \
    PHP_OPENSSL_LIBS="-L/usr/lib -lssl -lcrypto" \
    PHP_INI_DIR="/usr/local/etc/php"

RUN set -eux; \
        podman-php-source extract; \
        cd /usr/src/php; \
        mkdir -p "$PHP_INI_DIR/conf.d"; \
        \
        CPP=cpp \
        CFLAGS="$PHP_CFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
        CXXFLAGS="$PHP_CXXFLAGS" \
        OPENSSL_CFLAGS="$PHP_OPENSSL_CFLAGS" \
        OPENSSL_LIBS="$PHP_OPENSSL_LIBS" \
        PHP_UNAME="FreeBSD - Podman" \
        PHP_BUILD_PROVIDER=https://github.com/dmkos/php-containers \
        ./configure \
            # FreeBSD
            --program-prefix= \
            --prefix=/usr/local \
            --with-layout=GNU \
            --infodir=/usr/local/share/info/ \
            --localstatedir=/var \
            --mandir=/usr/local/share/man \
            # Adapted from Docker
            --with-config-file-path="$PHP_INI_DIR" \
            --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
            --enable-option-checking=fatal \
            --with-mhash \
            --with-pic \
            --enable-mbstring \
            --enable-mysqlnd \
            --with-password-argon2=/usr/local \
            --with-sodium=shared \
            --with-pdo-sqlite=/usr/local \
            --with-sqlite3=/usr/local \
            --with-curl \
            --with-iconv=/usr/local \
            --with-openssl \
            --with-readline \
            --with-zlib \
            --enable-phpdbg \
            --enable-phpdbg-readline \
            --with-pear \
            --enable-embed \
            # FrankenPHP
            --enable-zts \
            --disable-zend-signals; \
        \
        make -j "$(nproc)"; \
        make install; \
        strip --strip-all /usr/local/bin/perl; \
        strip --strip-all /usr/local/bin/php-cgi; \
        strip --strip-all /usr/local/bin/php; \
        strip --strip-all /usr/local/bin/phpdbg; \
        strip --strip-all /usr/local/lib/libphp.so; \
        find /usr/local/lib/php \
            -type f \
            -name '*.so' \
            -exec sh -euxc 'strip --strip-all "$@" || :' sh {} +; \
        make clean; \
        cp -v php.ini-* "$PHP_INI_DIR/"; \
        pecl update-channels; \
        rm -rf /tmp/pear /.pearrc; \
        # smoke test
        php --version; \
        podman-php-ext-enable opcache; \
        podman-php-ext-enable sodium; \
        cd /; \
	podman-php-source delete

# Compile watcher-c
# https://github.com/e-dant/watcher/tree/release/watcher-c
RUN set -eux; \
        tar xzf /usr/src/watcher.tar.gz -C /usr/src; \
        cd /usr/src/watcher-${WATCHER_VERSION}/watcher-c; \
        c++ -o libwatcher-c.so ./src/watcher-c.cpp -I ./include -I ../include -std=c++17 -fPIC -shared; \
        strip --strip-all libwatcher-c.so; \
        cp libwatcher-c.so /usr/local/lib/; \
        cp -R include/wtr /usr/local/include; \
        cd /; \
        rm -rf /usr/src/watcher-${WATCHER_VERSION}

# Compile FrankenPHP without xcaddy
# https://frankenphp.dev/docs/compile/#without-xcaddy
RUN set -eux; \
        tar xzf /usr/src/frankenphp.tar.gz -C /usr/src; \
        cd /usr/src/frankenphp-${FRANKENPHP_VERSION}/caddy/frankenphp; \
        go telemetry off; \
        \
        CGO_CFLAGS="-DFRANKENPHP_VERSION=v${FRANKENPHP_VERSION} $(php-config --includes) -I/usr/local/include" \
        CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
        go build -tags=nobadger,nomysql,nopgx; \
        strip --strip-all frankenphp; \
        \
        # smoke test
        ./frankenphp version; \
        mkdir -p /usr/local/etc/frankenphp/Caddyfile.d; \
        mv frankenphp /usr/local/bin/; \
        cp Caddyfile /usr/local/etc/frankenphp/; \
        go clean -cache -modcache; \
        cd /; \
        rm -rf /usr/src/frankenphp-${FRANKENPHP_VERSION}

# Set up directories in FreeBSD style
ENV XDG_CONFIG_HOME=/var/db/frankenphp/config \
    XDG_DATA_HOME=/var/db/frankenphp/data
RUN set -eux; \
        mkdir -p $XDG_CONFIG_HOME; \
        mkdir -p $XDG_DATA_HOME; \
        mkdir -p /usr/local/www/app/public; \
        echo '<?php phpinfo(); ?>' > /usr/local/www/app/public/index.php

COPY --chmod=755 bin/podman-php-entrypoint /usr/local/bin/
ENTRYPOINT ["podman-php-entrypoint"]

WORKDIR /usr/local/www/app
CMD ["--config", "/usr/local/etc/frankenphp/Caddyfile"]

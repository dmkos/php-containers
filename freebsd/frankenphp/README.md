# FreeBSD FrankenPHP

[FrankenPHP](https://frankenphp.dev/) images for FreeBSD + Podman.
Specific versions of PHP and FrankenPHP are compiled. In FreeBSD 14, this
resulted as two different containers for build and run in production environment,
while FreeBSD 15, with the introduction of a base `toolchain` image,
including compiler, no longer requires separate images.

> [!important]
> In production FreeBSD 14 image the `www` user (80:80) is set explicitly.

## Tags

The tags mostly follow original FrankenPHP
[pattern](https://frankenphp.dev/docs/docker/) with `frankenphp` prefix and
fewer combinations along with PHP versions at the beginning. I recommend
`8.4-frankenphp-freebsd` and `8.4-frankenphp-builder-freebsd`.

* PHP 8.4:
    * [`8.4.18-frankenphp-1.11.3-freebsd14.3`,         `8.4-frankenphp-1.11-freebsd14`,         `8.4-frankenphp-freebsd`,         `frankenphp-1.11.3-php8.4.18-freebsd14.3`,         `frankenphp-1.11-php8.4-freebsd14`,         `frankenphp-php8.4-freebsd`        ](./variations/8.4-14.3/runner.containerfile) - end-user FreeBSD 14 "runner" image
    * [`8.4.18-frankenphp-1.11.3-builder-freebsd14.3`, `8.4-frankenphp-1.11-builder-freebsd14`, `8.4-frankenphp-builder-freebsd`, `frankenphp-1.11.3-builder-php8.4.18-freebsd14.3`, `frankenphp-1.11-builder-php8.4-freebsd14`, `frankenphp-builder-php8.4-freebsd`](./variations/8.4-14.3/builder.containerfile) - FreeBSD 14 builder image
* PHP 8.5:
    * [`8.5.3-frankenphp-1.11.3-freebsd-15.0`,        `8.5-frankenphp-1.11-freebsd-15`,        `8.5-frankenphp-freebsd-15`,                                      `frankenphp-1.11.3-php8.5.3-freebsd15.0`,         `frankenphp-1.11-php8.5-freebsd15`,                                              `frankenphp-php8.5-freebsd15`                                    ](./variations/8.5-15.0/Containerfile) - single FreeBSD 15 image
    * [`8.5.3-frankenphp-1.11.3-freebsd14.3`,         `8.5-frankenphp-1.11-freebsd14`,         `8.5-frankenphp-freebsd`,         `8-frankenphp-freebsd`,         `frankenphp-1.11.3-php8.5.3-freebsd14.3`,         `frankenphp-1.11-php8.5-freebsd14`,         `frankenphp-1-php8-freebsd`,         `frankenphp-php8.5-freebsd`,         `frankenphp-freebsd`        ](./variations/8.5-14.3/runner.containerfile) - end-user FreeBSD 14 "runner" image
    * [`8.5.3-frankenphp-1.11.3-builder-freebsd14.3`, `8.5-frankenphp-1.11-builder-freebsd14`, `8.5-frankenphp-builder-freebsd`, `8-frankenphp-builder-freebsd`, `frankenphp-1.11.3-builder-php8.5.3-freebsd14.3`, `frankenphp-1.11-builder-php8.5-freebsd14`, `frankenphp-1-builder-php8-freebsd`, `frankenphp-builder-php8.5-freebsd`, `frankenphp-builder-freebsd`](./variations/8.5-14.3/builder.containerfile) - FreeBSD 14 builder image

> [!warning]
> Since PHP 8.5.4, default tags will be for FreeBSD 15, breaking backward compatibility. Consider upgrade or use a more specific tag.

## Usage

Images available at Container Registry and Docker Hub.

* https://github.com/dmkos/php-containers/pkgs/container/php
* https://hub.docker.com/r/dmkos/php-freebsd

Below is about end-user FreeBSD 14 container or the single FreeBSD 15 image.

> [!warning]
> Never use builder image in production environment.

### Getting started

Assume `index.php` is placed in `public` subdirectory of current
(e.g. Symfony, Laravel).

FreeBSD 14:

```shell
podman run -v $PWD:/usr/local/www/app \
    -p 80:10080 -p 443:10443 \
    ghcr.io/dmkos/php:frankenphp-freebsd
```

FreeBSD 15:

```shell
podman run -v $PWD:/usr/local/www/app \
    -p 80:80 -p 443:443 \
    ghcr.io/dmkos/php:8.5-frankenphp-freebsd-15
```

Visit `https://localhost` and accept self-signed certificate or run `curl`:

```shell
curl -vkL localhost
```

### PHP configuration

You have to choose php.ini edition for development or production environment.

```dockerfile
FROM ghcr.io/dmkos/php:frankenphp-freebsd

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
```

### Running as an arbitrary user

#### FreeBSD 14

As mentioned above the runner image is configured for unprivileged `www` user.
That is why server listens on high port numbers. Source code should be available
for that user.

The builder image is not attended to run as non-root user.

#### FreeBSD 15

To run as an unprivileged user, you must change the ownership of
FrankenPHP's internal configuration and data directories, and use
ports 1024 and above.

```dockerfile
FROM ghcr.io/dmkos/php:8.5-frankenphp-freebsd-15

# Run as a Non-Root User
# https://frankenphp.dev/docs/docker/#running-as-a-non-root-user
ARG USER=www
RUN set -eux; \
        # create new user
        if ! id ${USER}; then \
            pw useradd ${USER} -m; \
        fi; \
        # give write access to internal config and data directories
        chown -R ${USER}:${USER} /var/db/frankenphp; \
        # use non-privileged ports (1024 and above)
        sed -i '' 's/{$CADDY_GLOBAL_OPTIONS}/http_port 10080\n        https_port 10443\n        {$CADDY_GLOBAL_OPTIONS}/' /usr/local/etc/frankenphp/Caddyfile

EXPOSE 10080/tcp 10443/tcp 10443/udp
USER ${USER}
```

### FreeBSD differences

Container for FreeBSD 14 exposes `10080/tcp` port for HTTP,
`10443/tcp` for HTTPS and HTTP/2 among with `10443/udp` for HTTP/3.
In FreeBSD 15 the standard ports (80 and 443) are used by default.

Application directory:

* `/usr/local/www/app`

Caddyfile location:

* `/usr/local/etc/frankenphp/Caddyfile`

Persistent Caddy (FrankenPHP) directories:

* `/var/db/frankenphp/config`
* `/var/db/frankenphp/data`

> [!note]
> [`HEALTHCHECK`](https://docs.docker.com/reference/dockerfile/#healthcheck) is not used due to incompatibility with the OCI format.

[`compose.yaml`](./examples/basic/compose.yaml) example including
[`Containerfile`](./examples/basic/Containerfile) with production php.ini:

```yaml
services:
  php:
    build: .
    restart: always
    environment:
      SERVER_NAME: "example.com"
    ports:
      - "80:10080" # HTTP
      - "443:10443" # HTTPS
      - "443:10443/udp" # HTTP/3
    volumes:
      - ./app:/usr/local/www/app
      - franken_config:/var/db/frankenphp/config
      - franken_data:/var/db/frankenphp/data

volumes:
  franken_config:
  franken_data:
```

### FrankenPHP configuration

FrankenPHP can be configured according to [documentation](https://frankenphp.dev/docs/config/)
with FreeBSD specifics.

Provided `Caddyfile` accepts following environment variables:

* `CADDY_GLOBAL_OPTIONS`: inject [global options](https://caddyserver.com/docs/caddyfile/options)
* `FRANKENPHP_CONFIG`: inject config under the `frankenphp` directive
* `CADDY_EXTRA_CONFIG`: custom configuration, maybe
[snippets](https://caddyserver.com/docs/caddyfile/concepts#snippets)
or www redirects
* `SERVER_NAME`: [address](https://caddyserver.com/docs/caddyfile/concepts#addresses)
on which to listen, the provided hostname will also be used for the generated TLS certificate
* `SERVER_ROOT`: change the root directory of the site, defaults to `public/`
relative to container working directory
* `CADDY_SERVER_EXTRA_DIRECTIVES`: additional settings of the default server,
e.g. [Mercure hub](https://frankenphp.dev/docs/mercure/) and/or vulcain modules

[`compose.yaml`](./examples/watcher/compose.yaml) example for
[worker mode](https://frankenphp.dev/docs/worker/) (Symfony framework expected):

```yaml
services:
  php:
    build: .
    restart: always
    environment:
      FRANKENPHP_CONFIG: |
        worker {
          file ./public/index.php
          num 1
          watch
        }
      APP_RUNTIME: Runtime\FrankenPhpSymfony\Runtime
      CADDY_GLOBAL_OPTIONS: "auto_https off"
      SERVER_NAME: "http://"
    ports:
      - "80:10080"
    volumes:
      - ./app:/usr/local/www/app
      - franken_config:/var/db/frankenphp/config
      - franken_data:/var/db/frankenphp/data

volumes:
  franken_config:
  franken_data:
```

Feel free to bind mount directory with additional `*.caddyfile` into
`/usr/local/etc/frankenphp/Caddyfile.d` or replace whole configuration:

```yaml
    volumes:
      - ./config:/usr/local/etc/frankenphp
```

### Composer

In FreeBSD 14 it is preinstalled with unzip.

In FreeBSD 15 it is up to you, e.g.:

```dockerfile
# Composer's official Docker image
FROM --platform=linux/amd64 docker.io/library/composer:2 AS composer

FROM ghcr.io/dmkos/php:8.5-frankenphp-freebsd-15

# Install composer from image
COPY --from=composer /usr/bin/composer /usr/local/bin/
```

## PHP extensions

### Provided extensions

#### FreeBSD 14

The image includes all "official" extensions as well as:

* bcmath
* bz2
* gd
* intl
* pcntl
* pdo_mysql
* pdo_pgsql
* pgsql

And also PECL [uploadprogress](https://pecl.php.net/package/uploadprogress)
as an example.

#### FreeBSD 15

The list of extensions corresponds to the official image for Docker.

### Installing extensions

The way we do it is almost the same as
[official](https://hub.docker.com/_/php#how-to-install-more-php-extensions).
Please replace `docker` prefix into `podman`: `podman-php-ext-install` and so on.

For example, install gd extension:

```Dockerfile
# Install dependencies
RUN set -eux; \
    pkg install -y \
        graphics/libavif \
        graphics/png \
        graphics/webp \
        print/freetype2 \
        x11/libXpm \
    ; \
    # cleanup
    pkg clean -ay; \
    rm -rf /var/db/pkg/repos

# Build and install additional PHP extensions
RUN set -eux; \
    podman-php-ext-configure gd --with-webp --with-jpeg --with-xpm --with-freetype --with-avif; \
    podman-php-ext-install -j"$(nproc)" gd; \
    # smoke test
    php -m | grep gd
```

Visit [FreeBSD FreshPorts](https://www.freshports.org/lang/php85/)
to track required dependencies.

The FreeBSD 14 specifics are discussed below.

## Builder image (FreeBSD 14)

Unfortunately, one does not simply install more PHP extensions. To do that you
need compiler, linker and other build tools comes with FreeBSD. In other words,
they cannot be installed via package manager. Therefore, it was decided to
extract entire base system into image similar to
[creating a jail](https://docs.freebsd.org/en/books/handbook/jails/#thin-jail).

```Dockerfile
RUN set -eux; \
    cd /; \
    fetch https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz; \
    # ignore permission warnings during extraction
    tar xf base.txz -C / --keep-old-files --exclude=rescue || true; \
    rm base.txz
```

> [!caution]
> The operation immediately adds about 900 MB to the image.

### Creating end-user image

To avoid having to drag literally the entire FreeBSD installation to your
system, you should implement multi-stage build similar to
[`runner.containerfile`](./variations/8.4-14.3/runner.containerfile).
At the first stage install additional extensions as described above.
Then build final image by copying PHP from previous step.

> [!warning]
> You need to install (again) all external dependencies of PHP and its extensions using `pkg`.

```Dockerfile
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
        graphics/libavif \
        graphics/png \
        graphics/webp \
        print/freetype2 \
        x11/libXpm \
    ; \
    # cleanup
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
```

Next operations in `runner.containerfile` are about setting up files and
directories permissions, configure FrankenPHP and the container to run under
non-root user. Hope it self-documented.

## See also

* [Installing Podman on FreeBSD](https://podman.io/docs/installation#installing-on-freebsd)
* [dunglas/frankenphp - Docker Image](https://hub.docker.com/r/dunglas/frankenphp)

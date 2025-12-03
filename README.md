# PHP Containers

This repository contains different container images of PHP. For details, see
the corresponding `README.md` files.

For your convenience, images pull URL is:

```
ghcr.io/dmkos/php
```

Specify tag from list below.

## Supported tags

* [`8.4-fpm-freebsd14.3-pkg`, `8.4-fpm-freebsd-pkg`](./freebsd/fpm-pkg/variations/8.4-14.3/Containerfile)
* [`8.4.15-frankenphp-1.10.1-freebsd14.3`,         `8.4-frankenphp-1.10-freebsd14`,         `8.4-frankenphp-freebsd`,         `frankenphp-1.10.1-php8.4.15-freebsd14.3`,         `frankenphp-1.10-php8.4-freebsd14`,         `frankenphp-php8.4-freebsd`        ](./freebsd/frankenphp/variations/8.4-14.3/runner.containerfile)
* [`8.4.15-frankenphp-1.10.1-builder-freebsd14.3`, `8.4-frankenphp-1.10-builder-freebsd14`, `8.4-frankenphp-builder-freebsd`, `frankenphp-1.10.1-builder-php8.4.15-freebsd14.3`, `frankenphp-1.10-builder-php8.4-freebsd14`, `frankenphp-builder-php8.4-freebsd`](./freebsd/frankenphp/variations/8.4-14.3/builder.containerfile)
* [`8.5.0-frankenphp-1.10.1-freebsd14.3`,         `8.5-frankenphp-1.10-freebsd14`,         `8.5-frankenphp-freebsd`,         `8-frankenphp-freebsd`,         `frankenphp-1.10.1-php8.5.0-freebsd14.3`,         `frankenphp-1.10-php8.5-freebsd14`,         `frankenphp-1-php8-freebsd`,         `frankenphp-php8.5-freebsd`,         `frankenphp-freebsd`](./freebsd/frankenphp/variations/8.5-14.3/runner.containerfile)
* [`8.5.0-frankenphp-1.10.1-builder-freebsd14.3`, `8.5-frankenphp-1.10-builder-freebsd14`, `8.5-frankenphp-builder-freebsd`, `8-frankenphp-builder-freebsd`, `frankenphp-1.10.1-builder-php8.5.0-freebsd14.3`, `frankenphp-1.10-builder-php8.5-freebsd14`, `frankenphp-1-builder-php8-freebsd`, `frankenphp-builder-php8.5-freebsd`, `frankenphp-builder-freebsd`](./freebsd/frankenphp/variations/8.5-14.3/builder.containerfile)
* [`8.4.15-lighttpd-1.4.82-trixie`,    `8.4.15-lighttpd-1.4-trixie`,    `8.4.15-lighttpd-trixie`,    `8.4-lighttpd-1.4-trixie`,    `8.4-lighttpd-trixie`,    `8.4.15-lighttpd`,    `8.4-lighttpd-1.4`,    `8.4-lighttpd`   ](./linux/lighttpd/variations/8.4/trixie/Dockerfile)
* [`8.4.15-lighttpd-1.4.82-s6-trixie`, `8.4.15-lighttpd-1.4-s6-trixie`, `8.4.15-lighttpd-s6-trixie`, `8.4-lighttpd-1.4-s6-trixie`, `8.4-lighttpd-s6-trixie`, `8.4.15-lighttpd-s6`, `8.4-lighttpd-1.4-s6`, `8.4-lighttpd-s6`](./linux/lighttpd/variations/8.4/trixie/s6.dockerfile)
* [`8.4.15-lighttpd-1.4.82-alpine`,    `8.4.15-lighttpd-1.4-alpine`,    `8.4.15-lighttpd-alpine`,    `8.4-lighttpd-1.4-alpine`,    `8.4-lighttpd-alpine`   ](./linux/lighttpd/variations/8.4/alpine/Dockerfile)
* [`8.4.15-lighttpd-1.4.82-s6-alpine`, `8.4.15-lighttpd-1.4-s6-alpine`, `8.4.15-lighttpd-s6-alpine`, `8.4-lighttpd-1.4-s6-alpine`, `8.4-lighttpd-s6-alpine`](./linux/lighttpd/variations/8.4/alpine/s6.dockerfile)
* [`8.5.0-lighttpd-1.4.82-trixie`,    `8.5.0-lighttpd-1.4-trixie`,    `8.5.0-lighttpd-trixie`,    `8.5-lighttpd-1.4-trixie`,    `8.5-lighttpd-trixie`,    `8-lighttpd-trixie`,    `lighttpd-trixie`,    `8.5.0-lighttpd`,    `8.5-lighttpd-1.4`,    `8.5-lighttpd`,    `8-lighttpd`,    `lighttpd`](./linux/lighttpd/variations/8.5/trixie/Dockerfile)
* [`8.5.0-lighttpd-1.4.82-s6-trixie`, `8.5.0-lighttpd-1.4-s6-trixie`, `8.5.0-lighttpd-s6-trixie`, `8.5-lighttpd-1.4-s6-trixie`, `8.5-lighttpd-s6-trixie`, `8-lighttpd-s6-trixie`, `lighttpd-s6-trixie`, `8.5.0-lighttpd-s6`, `8.5-lighttpd-1.4-s6`, `8.5-lighttpd-s6`, `8-lighttpd-s6`, `lighttpd-s6`](./linux/lighttpd/variations/8.5/trixie/s6.dockerfile)
* [`8.5.0-lighttpd-1.4.82-alpine`,    `8.5.0-lighttpd-1.4-alpine`,    `8.5.0-lighttpd-alpine`,    `8.5-lighttpd-1.4-alpine`,    `8.5-lighttpd-alpine`,    `8-lighttpd-alpine`,    `lighttpd-alpine`   ](./linux/lighttpd/variations/8.5/alpine/Dockerfile)
* [`8.5.0-lighttpd-1.4.82-s6-alpine`, `8.5.0-lighttpd-1.4-s6-alpine`, `8.5.0-lighttpd-s6-alpine`, `8.5-lighttpd-1.4-s6-alpine`, `8.5-lighttpd-s6-alpine`, `8-lighttpd-s6-alpine`, `lighttpd-s6-alpine`](./linux/lighttpd/variations/8.5/alpine/s6.dockerfile)

## FreeBSD

FreeBSD containers intend to use with Podman. Please install it according to
[manual](https://podman.io/docs/installation#installing-on-freebsd-140).

### fpm-pkg

PHP-FPM container example as closest as possible to official. PHP installed
via a package manager, which does not guarantee the exact version.

[README.md](./freebsd/fpm-pkg/README.md)

### FrankenPHP

There are two images: builder and runner (end-user). The latter is configured
to run under unprivileged `www` user and also includes some additional PHP
extensions and `composer`.

[README.md](./freebsd/frankenphp/README.md)

## Linux

Linux containers probably will be used with Docker. Installation methods vary,
the most common are described in the [documentation](https://docs.docker.com/engine/install/).

### Lighttpd

Lighttpd web server on top of php:fpm official image. Containers are intended
to be used with reverse proxy such as Traefik or HAPorxy, therefore access
logs are disabled. The server is built from source and listens 9000 port
(while PHP-FPM - socket).

[README.md](./linux/lighttpd/README.md)

## Feedback

Feel free to create any [issues](https://github.com/dmkos/php-containers/issues).

[Pull requests](https://github.com/dmkos/php-containers/pulls) are would be really appreciated.

## See also

* [My Docker Hub profile](https://hub.docker.com/u/dmkos)
* [PHP official images](https://hub.docker.com/_/php)
* [FreeBSD Docker Hub profile](https://hub.docker.com/u/freebsd)
* [Контейнеры PHP](https://git.dmkos.ru/containers/php) which is "mirror"
of this repository.

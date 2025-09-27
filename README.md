# PHP Containers

This repository contains different container images of PHP. For details, see
the corresponding `README.md` files.

For your convenience, images pull URL is:

```
ghcr.io/dmkos/php
```

Specify tag from list below.

## Supported tags

* [`8.4-fpm-freebsd14.3-pkg`](./freebsd/fpm-pkg/8.4/Containerfile)
* [`frankenphp-1.9.1-php8.4.12-freebsd14.3`, `frankenphp-1.9-php8.4-freebsd14`, `frankenphp-1-php8-freebsd`, `frankenphp-php8.4-freebsd`, `frankenphp-freebsd`](./freebsd/frankenphp/8.4-14.3/runner.containerfile)
* [`frankenphp-1.9.1-builder-php8.4.12-freebsd14.3`, `frankenphp-1.9-builder-php8.4-freebsd14`, `frankenphp-1-builder-php8-freebsd`, `frankenphp-builder-php8.4-freebsd`, `frankenphp-builder-freebsd`](./freebsd/frankenphp/8.4-14.3/builder.containerfile)
* [`8.4.13-lighttpd-1.4.82-trixie`, `8.4.13-lighttpd-trixie`, `8.4-lighttpd-trixie`, `8-lighttpd-trixie`, `lighttpd-trixie`, `8.4.13-lighttpd`, `8.4-lighttpd`, `8-lighttpd`, `lighttpd`](./linux/lighttpd/8.4/trixie/Dockerfile)

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
to be used with reverse proxy such as Traefik (recommended), therefore access
logs are disabled. The server is built from source and listens 9000 port
(while PHP-FPM - socket).

[README.md](./linux/lighttpd/README.md)

## Feedback

Feel free to create any [issues](https://github.com/dmkos/php-containers/issues).

[Pull requests](https://github.com/dmkos/php-containers/pulls) are would be really appreciated.

## Links

* [My Docker Hub profile](https://hub.docker.com/u/dmkos)
* [PHP official images](https://hub.docker.com/_/php)
* [FreeBSD Docker Hub profile](https://hub.docker.com/u/freebsd)
* [Контейнеры PHP](https://git.dmkos.ru/containers/php) which is "mirror"
of this repository.

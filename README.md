# PHP Containers

This repository contains different container images of PHP. For details, see
the corresponding `README.md` files.

## FreeBSD

FreeBSD containers intend to use with Podman. Please install it according to
[manual](https://podman.io/docs/installation#installing-on-freebsd-140).

### fpm-pkg

PHP-FPM container example as closest as possible to official. PHP installed
via a package manager, which does not guarantee the exact version.

Supported tags and respective `Containerfile` links:

* [`8.4-fpm-freebsd14.3-pkg`](./freebsd/fpm-pkg/8.4/Containerfile)

[README.md](./freebsd/fpm-pkg/README.md)

## Links

* [My Docker Hub profile](https://hub.docker.com/u/dmkos)
* [PHP official images](https://hub.docker.com/_/php)
* [FreeBSD Docker Hub profile](https://hub.docker.com/u/freebsd)
* [Контейнеры PHP](https://git.dmkos.ru/dmkos/php-containers) which is "mirror"
of this repository.

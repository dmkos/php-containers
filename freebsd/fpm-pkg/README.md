# FreeBSD PHP-FPM (pkg)

The closest possible recreation of [official image](https://hub.docker.com/_/php)
php:8.4-fpm in concept as a whole and used extensions in particular with bear
in mind FreeBSD specifics. The package management tool is used for PHP
installation which does not guarantee exact version.

## Usage

Image published at Container Registry and Docker Hub.

* https://github.com/dmkos/php-containers/pkgs/container/php
* https://hub.docker.com/r/dmkos/php-freebsd

### Tags

* [`8.4-fpm-freebsd14.3-pkg`, `8.4-fpm-freebsd-pkg`](./8.4/Containerfile): PHP 8.4, FPM, FreeBSD 14.3.
PHP installed via the package manager.

For historical reasons I decided to keep tags like `8.4.12-fpm-freebsd14.3-pkg`
indicating PHP version at build time but you should avoid using it.

### Configuration

You have to choose php.ini variant for development or production environment.

```dockerfile
FROM ghcr.io/dmkos/php:8.4-fpm-freebsd-pkg

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
```

### Running as an arbitrary user

Not applicable. Podman's rootless mode is not yet supported on FreeBSD.
In theory you can set up file permissions for running master process as an
unprivileged user, but probably it's not neccessary. Owner of child processes,
which are do all the work, is `www`.

### Run a single PHP script

It is possible, but not a main purpose of the container.

```shell
podman run -it --rm -v "$PWD":/usr/local/www/html ghcr.io/dmkos/php:8.4-fpm-freebsd-pkg php your-script.php
```

### Install more PHP extensions

You can do it with `pkg`. When installing new extension PHP and others
are not automatically upgraded. You should manually upgrade it first to avoid
possible version conflicts.

Assume you want to install gd along with intl:

```dockerfile
FROM ghcr.io/dmkos/php:8.4-fpm-freebsd-pkg

# Install PHP extensions
RUN set -eux; \
        pkg upgrade -xy ^php84; \
        pkg install -y \
            php84-gd \
            php84-intl; \
        pkg clean -ay; \
        rm -rf /var/db/pkg/repos
```

### Composer installation

In our case, consider install composer with the package manager too, because
we can also get unzip for help:

```dockerfile
FROM ghcr.io/dmkos/php:8.4-fpm-freebsd-pkg

# Install composer and unzip
RUN set -eux; \
        pkg install -y \
            php84-composer \
            unzip; \
        pkg clean -ay; \
        rm -rf /var/db/pkg/repos
```

### Web server

Until the problem with service discovery is solved, you'll have to install it
on host sytem. Never expose 9000 port to public. `compose.yaml` example:

```yaml
services:
  php:
    image: ghcr.io/dmkos/php:8.4-fpm-freebsd-pkg
    restart: always
    ports:
      - "127.0.0.1:9000:9000"
    volumes:
      - ./myapp:/usr/local/www/html
```

Or corresponding command:

```shell
podman run -d -p "127.0.0.1:9000":9000 --name php -v "$PWD/myapp":/usr/local/www/html --restart always ghcr.io/dmkos/php:8.4-fpm-freebsd-pkg
```

I recommend [Caddy](https://caddyserver.com/) as web server. Install:

```shell
pkg install caddy security/portacl-rc
sysrc portacl_users+=www
sysrc portacl_user_www_tcp="http https"
sysrc portacl_user_www_udp="https"
service portacl enable
service portacl start
sysrc caddy_user=www caddy_group=www
service caddy enable
```

Basic configuration:

```
{
    email admin@example.com
}

example.com {
    root * /usr/local/www/myapp/public
    encode zstd br gzip
    php_fastcgi 127.0.0.1:9000 {
        root /usr/local/www/html/public
    }
    file_server
}
```

Run:

```shell
service caddy start
```

## Issues

### Packages upgrade

`pkg upgrade -y` command doesn't work with error message like this:

> pkg: Fail to rename /etc/.pkgtemp.hosts.Y25WIgCpWhrB -> /etc/hosts:Cross-device link

It is probably because `/etc/hosts` placed in layer of freebsd-runtime image
while upgrade command works in its own. So Podman or ZFS may not be prepared for
such situation.

### Service discovery

For illustration purposes I have prepared [example](./examples/caddy)
of simple `compose.yaml` with very basic Caddy configuration. Linux emulation
must be enabled:

```shell
service linux enable
service linux start
podman-compose up -d
```

During request attempt you will receive `502 Bad Gateway` response with
logged error like `dial tcp: lookup php on xxx.xxx.xxx.xxx:53: no such host`.

## See also

* [Installing Podman on FreeBSD 14.0](https://podman.io/docs/installation#installing-on-freebsd-140)
* [Образ PHP для Podman во FreeBSD](https://comp.dmkos.ru/publ/obraz-php-dla-podman-vo-freebsd/)
* [php:8.4-fpm](https://github.com/docker-library/php/blob/master/8.4/bookworm/fpm/Dockerfile)

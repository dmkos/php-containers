# Linux Lighttpd

[Lighttpd](https://www.lighttpd.net/) web server on top of `php:fpm`
[official image](https://hub.docker.com/_/php).
Containers are intended to use with reverse proxy such as
[Traefik](https://doc.traefik.io/traefik/getting-started/quick-start/)
(recommended), therefore access logs are disabled.
The server is built from source and listens 9000 port (while PHP-FPM - socket).

## Supported tags

Naming scheme follows official `php:apache` combinations with additional tag
indicating exact Lighttpd version. I suggest using a tag like `8.4-lighttpd`.

* [`8.4.13-lighttpd-1.4.82-trixie`, `8.4.13-lighttpd-trixie`, `8.4-lighttpd-trixie`, `8-lighttpd-trixie`, `lighttpd-trixie`, `8.4.13-lighttpd`, `8.4-lighttpd`, `8-lighttpd`, `lighttpd`](./8.4/trixie/Dockerfile) - unprivileged Debian-based image

Images can be found on GitHub and Docker Hub:

* [GitHub](https://github.com/dmkos/php-containers/pkgs/container/php): `ghcr.io/dmkos/php`
* [Docker Hub](https://hub.docker.com/r/dmkos/php): `dmkos/php`

The latter used in examples below.

## Usage

In order for popular PHP frameworks to work at least you need to define URL
rewrite rules and override the server's document root.

> [!important]
> Unprivileged image have `www-data` (33:33) user set explicitly.

> [!note]
> `composer` and `unzip` are both included.

### Environment variables

The following environment variables are used and exposed in the dockerfile:

* `LIGHTTPD_PORT` - web server port, default `9000`;
* `LIGHTTPD_DOCUMENT_ROOT` - web server document root, default `/var/www/html`.
Override depending on application design;
* `HEALTHCHECK_PATH` - path (URL) for container's health check.
Leading slash is required. Requested resource must return HTTP code `200`. 
By default script is polling the Lighttpd [status](https://redmine.lighttpd.net/projects/lighttpd/wiki/Mod_status).
I recommend using a specific endpoint, e.g. `/up` for [Laravel](https://laravel.com/docs/12.x/deployment#the-health-route).

### Configure Lighttpd

There are three common ways:

1. Bind directory with local configuration files, such as rewrite rules, to `/usr/local/etc/lighttpd/conf.d`.
I think this covers most use cases.
2. Pass individual files to `/etc/lighttpd/conf.d`, especially if you
need to enable some modules before [fastcgi](https://redmine.lighttpd.net/projects/lighttpd/wiki/Mod_fastcgi).
3. Replace the whole `/etc/lighttpd/conf.d` directory with
[configuration](https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_ConfigurationOptions)
written from scratch. Hope you don't have to use such radical method.

And 4th is somehow to combine 1st and 2nd ones.

E.g. [rewrite URL](https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_ModRewrite)
for Symfony framework and others with the same principle:

```conf
# index.php expects original URL in PATH_INFO
url.rewrite-if-not-file = ( "" => "/index.php${url.path}${qsa}" )
```

If uploading files is allowed to your site users I suggest to
[deny access](https://redmine.lighttpd.net/projects/lighttpd/wiki/Mod_access)
to `*.php` files in public directory. E.g.:

```conf
$HTTP["url"] =~ "^/upload" {
    url.access-deny = ( ".php" )
}
```

Or you can allow access only to a certain types:

```conf
$HTTP["url"] =~ "^/upload" {
    url.access-allow = ( ".jpg", ".png" )
}
```

It is better to set up logging and compression at proxy server (Traefik).
Nevertheless activating [access logs](https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_ModAccessLog)
can be done with:

```conf
accesslog.filename = "/proc/self/fd/2"
```

In case of network traffic between the servers you can enable gzip like this:

```conf
##  Output Compression
## --------------------
##
## https://wiki.lighttpd.net/mod_deflate
##
server.modules += ( "mod_deflate" )

deflate.mimetypes = ( "text/*" )
deflate.allowed-encodings = ( "gzip", "deflate" )
```

### PHP configuration and extensions

Compared to official `php:fpm` image only logging, user, and socket settings
were modified, so you configure PHP and install extensions as usual.

> [!note]
> In unprivileged image you'll have to switch to `root` user and then back to `www-data`.

E.g.:

```dockerfile
FROM dmkos/php:8.4-lighttpd

# Switch to configure PHP
USER root

# Install PHP extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
        gd \
        intl

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Switch back to unprivileged user (required)
USER www-data
```

### Collaboration with Traefik

E.g. compose.yaml:

```yaml
services:
  app:
    build:
      context: .
    restart: always
    labels:
      - traefik.enable=true
      - traefik.http.routers.example.rule=Host(`example.com`)
    environment:
      LIGHTTPD_DOCUMENT_ROOT: /var/www/html/public
      SYMFONY_TRUSTED_PROXIES: private_ranges
    volumes:
      - ./config:/usr/local/etc/lighttpd/conf.d
      - ./src:/var/www/html
  proxy:
    image: traefik:v3.5
    restart: always
    # this is very basic configuration, please do not use in production
    command:
      - --api.insecure=true
      - --providers.docker.exposedbydefault=false
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

### Arbitrary user

If you're not happy with `www-data` for some reason (usually it is related
to file permissions of your source code), here is how to create custom user:

```dockerfile
FROM dmkos/php:8.4-lighttpd

# Switch to create user
USER root

ARG WWWUSER=1000 WWWNAME=lighty
RUN set -eux; \
        useradd -m -c 'World Wide Web Owner' -u $WWWUSER $WWWNAME; \
        chown ${WWWUSER}:${WWWUSER} /var/www/html

# Switch to newly created user
USER $WWWUSER
```

### Examples

* [Symfony Demo Application](./examples/demo) - basic usage with no persistence
* [Yii 2 Advanced Application](./examples/yii2-app-advanced) - serving several hosts

## Links

* [jitesoft/lighttpd](https://hub.docker.com/r/jitesoft/lighttpd) - Lighttpd images based on Alpine Linux
* [serversideup/php](https://hub.docker.com/r/serversideup/php) - unprivileged
PHP images (Apache, Nginx) with [s6-overlay](https://github.com/just-containers/s6-overlay)
init system and different improvements
* [Traefik: ваш прокcи для веб-приложений Docker](https://comp.dmkos.ru/publ/traefik-vas-prokci-dla-veb-prilozenij-docker/) - my Traefik overview (ru)
* [Образ Lighttpd для Docker и Traefik](https://comp.dmkos.ru/publ/obraz-lighttpd-dla-docker-i-traefik/)

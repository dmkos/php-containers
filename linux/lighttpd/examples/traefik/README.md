# Traefik

Advanced usage of Lighttpd container with
[Traefik](https://hub.docker.com/_/traefik)
by example of Symfony [Demo application](https://github.com/symfony/demo).

### Features

* Automatic issuance and renewal of Let's Encrypt [staging](https://letsencrypt.org/docs/staging-environment/) certificates
* HTTP/2 and HTTP/3 protocol support
* Redirect the scheme to https
* Redirect from www to non-www
* zstd, br, or gzip compression
* Web server's access log
* Extract the client's IP address from headers by web server
* Pretty URLs
* Docker socket isolation
* Run Traefik under unprivileged user

## Requirements

* VDS/VPS with Docker installed;
* domain `example.com` along with `www.example.com` subdomain pointing the server.

> [!note]
> You can use 3rd and 4th level domains e.g. `traefik.example.com` and `www.traefik.example.com`.

## Usage

Determine `docker` group ID:

```bash
getent group docker | cut -d: -f3
```

Create `.env` file. Provide domain name (without www) and obtained identifier:

```
DOMAIN_NAME=example.com
DOCKERGID=989
```

Prepare certificate storage:

```bash
touch config/traefik/acme.json
chown 405:100 config/traefik/acme.json
chmod 600 config/traefik/acme.json
```

To monitor access log, run the command:

```bash
docker compose up
```

After a while navigate the website. Since the certificate was issued in staging
environment, a warning will appear. Accept risks and open the site anyway.

Press <kbd>Ctrl+C</kbd> to terminate containers.

> [!caution]
> The application is deployed directly into container and doesn't provide persistence.

In other words, any content you've created, edited, etc., will be lost after
deleting the container.

## See also

* [socket-proxy](https://github.com/wollomatic/socket-proxy) - Docker unix socket isolation

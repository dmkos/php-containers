# HAProxy

An example of the Lighttpd web server running behind [HAProxy](https://www.haproxy.org/).

### Features

* Automatic issuance and renewal of Let's Encrypt [staging](https://letsencrypt.org/docs/staging-environment/) certificates
* HTTP/2 protocol support
* HAProxy and Lighttpd communication via HTTP/2 cleartext (h2c) protocol
* Redirect the scheme to https
* Redirect from www to non-www
* gzip compression
* Access logs of both proxy and web server
* PROXY protocol to preserve the client's IP address
* Pretty URLs

## Requirements

* VDS/VPS with Docker installed;
* domain `example.com` along with `www.example.com` subdomain pointing the server.

> [!note]
> You can use 3rd and 4th level domains e.g. `haproxy.example.com` and `www.haproxy.example.com`.

## Usage

Create `certs` and `src` subdirectories (add `sudo` if necessary):

```bash
mkdir certs
chown 99:99 certs
mkdir src
chown 33:33 src
```

Install Symfony [Demo Application](https://github.com/symfony/demo).
To do this run container first:

```bash
docker compose run -it --rm php bash
```

Then, while in the container, execute following commands:

```bash
composer create-project symfony/symfony-demo .
exit
```

Create `.env` file. Indicate domain (without www) and contact e-mail for
Let's Encrypt:

```
DOMAIN_NAME=example.com
CONTACT_EMAIL=admin@example.com
```

To monitor the certificate issuance progress and access log, run the command:

```bash
docker compose up
```

Navigate website. Since the certificate was obtained in staging environment, a
warning will appear. Accept risks and open the site anyway.

Press <kbd>Ctrl+C</kbd> to terminate containers.

## How certification works

HAProxy container is based on the [official image](https://hub.docker.com/_/haproxy/)
with additional utilities and [s6-overlay](https://github.com/just-containers/s6-overlay)
init system on top of it.

On container start the [`prepare`](./sbin/prepare) script performs the
following actions:

* if there is no certificate, issues *expired* self-signed one;
* also creates Let's Encrypt account key if it doesn't exists.

Next the [main service](./s6-rc.d/haproxy/run) runs. Detecting an expired
certificate, HAProxy requests a new one from Let's Encrypt.

Since for now the certificate is stored in RAM, it needs to be persisted.
To achieve this on container shutdown but before the load balancer is stopped
the [`dumpssl`](./sbin/dumpssl) script is executed.

## See also

* [ACME protocol - Announcing HAProxy 3.2](https://www.haproxy.com/blog/announcing-haproxy-3-2#acme-protocol)
* [Не краткий обзор HAProxy на примере интеграции с Lighttpd](https://comp.dmkos.ru/publ/ne-kratkij-obzor-haproxy-na-primere-integracii-s-lighttpd/)

# Standalone

An example of the Lighttpd container running independently (without reverse
proxy) over HTTPS (HTTP/2) with automatic issue and renewal of SSL certificates
thanks to [s6-overlay](https://github.com/just-containers/s6-overlay) and
[dehydrated](https://github.com/dehydrated-io/dehydrated).

## Requirements

* VDS/VPS with Docker installed;
* domain `example.com` along with `www.example.com` subdomain pointing the server.

> [!note]
> You can use 3rd and 4th level domains e.g. `lighty.example.com` and `www.lighty.example.com`.

## Usage

Create `.env` file and indicate domain (without www):

```
SERVER_NAME=example.com
```

Let's Encrypt [staging environment](https://letsencrypt.org/docs/staging-environment/)
is used by default. Adjust settings in the [`dehydrated/config`](./dehydrated/config)
file if necessary. It is also recommended to specify an email address:

```
CONTACT_EMAIL=your-email@example.com
```

> [!warning]
> By running the container you accept CA's terms of service e.g. [Let's Encrypt Subscriber Agreement](https://letsencrypt.org/repository/#let-s-encrypt-subscriber-agreement).

To monitor the certificate issuance progress, run the command:

```bash
docker compose up
```

Navigate website. Since the certificate was obtained in staging environment, a
warning will appear. Accept risks and open the site anyway. PHP information
page should be displayed.

That's it. Press <kbd>Ctrl+C</kbd> to terminate container.

## How it works

Two services are declared in s6-rc.d: prepare of `oneshot` type and `longrun` renew.

On container start the [`prepare`](./sbin/prepare) script performs the
following actions:

* if there is no certificate, issues a self-signed one;
* creates [domains.txt](https://github.com/dehydrated-io/dehydrated/blob/master/docs/domains_txt.md)
file based on the `SERVER_NAME` variable;
* registers an account if the dehydrated doesn't have one.

The [`renew`](./sbin/renew) service runs after Lighttpd and in an infinite loop
interrupted by `SIGTERM`:

* performs check and renew certificates - `dehydrated -c`;
* if a new certificate is issued, reloads Lighttpd by `SIGUSR1`;
* sleeps for 12 to 24 hours.

## See also

* [Работа Lighttpd по HTTP/2 без посредников](https://comp.dmkos.ru/publ/rabota-lighttpd-po-http2-bez-posrednikov/)

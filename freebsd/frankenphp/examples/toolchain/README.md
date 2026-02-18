# Toolchain

Using a single toolchain-based FrankenPHP image for FreeBSD
by example of Symfony [Demo application](https://github.com/symfony/demo).

## Usage

This example requires a FreeBSD 15 server (virtual machine)
with Podman and `podman-compose` installed.

Provided [`Containerfile`](./Containerfile) shows installing sass,
some popular PHP extensions, composer, and switching to the unprivileged `www` user.

FrankenPHP is configured via [`compose.yaml`](./compose.yaml), including
[worker mode](https://frankenphp.dev/docs/worker/).

### Server name

The default value `http://` makes site available by IP address.
If you have a domain and the server operates in the Internet,
create a `.env` file:

```
SERVER_NAME=demo.example.com
```

> [!caution]
> This example uses PHP configuration for the development environment.

### Installing the demo application

Create `app` subdirectory and set `www` user as owner:

```shell
mkdir app
chown www:www app
```

Run container once:

```shell
podman-compose run --rm php sh
```

Once inside the container,
install the Symfony demo application using `composer`:

```shell
composer create-project symfony/symfony-demo .
```

`exit` from the container and run application as usual:

```shell
podman-compose up -d
```

After a little while, you can open the site in your browser.

## See also

* [Installing Podman on FreeBSD](https://podman.io/docs/installation#installing-on-freebsd)

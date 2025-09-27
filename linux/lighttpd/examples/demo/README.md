# Demo

Basic usage of Lighttpd container with [Traefik](https://hub.docker.com/_/traefik)
by example of Symfony [Demo application](https://github.com/symfony/demo).

## Usage

> [!caution]
> The application is deployed directly into container and doesn't provide persistence.

In other words, any content you've created, edited, etc., will be lost after
deleting the container.

### Hostname

The default is `demo.lighttpd.local`.
To change it create a .env file and enter required value:

```
TRAEFIK_HOST=demo.example.com
```

Associate the hostname with IP address of server (virtual machine).
On Linux or similar systems you edit `/etc/hosts`,
on Windows - `C:\Windows\System32\drivers\etc\hosts`.

```
192.168.56.103 demo.example.com
```

### Run

Common command is:

```bash
docker compose up -d
```

After a little while of starting the application, open the website in your browser.

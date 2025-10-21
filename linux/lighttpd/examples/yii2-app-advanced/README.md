# Yii 2 Advanced Application

[Lighttpd](https://www.lighttpd.net/) serves several hosts
using the [Advanced](https://github.com/yiisoft/yii2-app-advanced)
application template of PHP framework Yii 2 as an example.

## Install

Prepare the `src` directory owned by 33:33 or having 777 permissions:

```bash
mkdir src
sudo chown 33:33 src
```

Run container once:

```bash
docker compose run -it --rm php bash
```

> [!note]
> It is assumed that current user is a member of the `docker` group. Otherwise precede docker commands with `sudo`.

Install template via composer:

```bash
composer create-project --prefer-dist yiisoft/yii2-app-advanced .
```

Initialize the development environment:

```bash
./init --env=Development --overwrite=All --delete=All
```

Prepare the SQLite database:

```bash
mkdir common/data
touch common/data/db.sqlite
sed -i 's#mysql:host=localhost;dbname=yii2advanced#sqlite:@common/data/db.sqlite#' common/config/main-local.php
php yii migrate
```

Enable pretty URLs. E.g. remove the comment block starting with `/*` and
ending with `*/` around urlManager settings:

```bash
sed -i -r '/(\/\*|\*\/)/d' backend/config/main.php
sed -i -r '/(\/\*|\*\/)/d' frontend/config/main.php
```

Tell Yii that we'll use a proxy-server (Traefik) by specifying private
network addresses for trusted hosts:

```bash
sed -i "/cookieValidationKey/a 'trustedHosts' => ['private']," backend/config/main-local.php
sed -i "/cookieValidationKey/a 'trustedHosts' => ['private']," frontend/config/main-local.php
```

`exit` from the container.

## Usage

Default hosts are:

* `back.lighttpd.local` for backend (control panel);
* `front.lighttpd.local` for frontend (website).

Override them using the `.env` file if necessary, e.g.:

```
BACKEND_HOSTNAME = admin.example.com
FRONTEND_HOSTNAME = www.example.com
```

Associate given hostnames with the server's (virtual machine) IP address, e.g.:

```
192.168.56.103 admin.example.com
192.168.56.103 www.example.com
```

* Linux: `/etc/hosts`
* Windows: `C:\Windows\System32\drivers\etc\hosts`

Start the whole application:

```bash
docker compose up -d
```

After a while navigate the website and sign up.

Open a file from `src/frontend/runtime/mail` directory in your email client
and follow the link to complete registration.

Log in to the control panel.

## See also

* [Installation of Yii 2 Advanced](https://github.com/yiisoft/yii2-app-advanced/blob/master/docs/guide/start-installation.md)
* [Настройка Lighttpd для yii2-app-advanced](https://comp.dmkos.ru/publ/nastrojka-lighttpd-dla-yii2-app-advanced/)

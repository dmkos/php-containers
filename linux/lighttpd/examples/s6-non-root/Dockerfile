FROM dmkos/php:lighttpd-s6

ARG WWW_UID=1000
ARG WWW_USER=lighty
# change environment variable accordingly
ENV WWW_USER=$WWW_USER

RUN set -eux; \
        useradd -m -c 'World Wide Web Owner' -u $WWW_UID $WWW_USER; \
        echo '<?php phpinfo(); ?>' > /var/www/html/index.php; \
        chown -R ${WWW_USER}:${WWW_USER} /var/www/html

USER $WWW_USER

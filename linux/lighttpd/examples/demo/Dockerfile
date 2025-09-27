FROM dmkos/php:lighttpd

# Install Symfony Demo application
# https://github.com/symfony/demo
#
# Runs as www-data according to USER directive in the parent image.
RUN set -eux; \
        composer create-project symfony/symfony-demo /var/www/html


# Switch to configure PHP
USER root

# E.g. install PHP extension
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
        intl

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Switch back to unprivileged user (required)
USER www-data

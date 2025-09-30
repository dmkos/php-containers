FROM dmkos/php:8.4-lighttpd

# Switch to configure PHP
USER root
# Install required gd extension
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
        gd
# Use the default development configuration
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# Switch back
USER www-data

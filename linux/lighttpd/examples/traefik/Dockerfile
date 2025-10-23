FROM dmkos/php:lighttpd

# Install Symfony Demo application
# https://github.com/symfony/demo
RUN set -eux; \
        composer create-project symfony/symfony-demo /var/www/html

# Switch to configure PHP
USER root

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Switch back to unprivileged user (required)
USER www-data

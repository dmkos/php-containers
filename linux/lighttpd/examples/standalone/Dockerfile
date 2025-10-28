FROM dmkos/php:lighttpd-s6

# Install dehydrated
ADD --chmod=755 https://raw.githubusercontent.com/dehydrated-io/dehydrated/master/dehydrated /usr/local/bin/
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            bsdextrautils; \
        apt-get dist-clean

# Configure
COPY s6-rc.d/ /etc/s6-overlay/s6-rc.d/
COPY --chmod=700 sbin/ /usr/local/sbin/

# Fix healthcheck
RUN sed -i 's#http://127.0.0.1:${LIGHTTPD_PORT}#https://127.0.0.1:9443#g' /usr/local/bin/healthcheck

EXPOSE 9443

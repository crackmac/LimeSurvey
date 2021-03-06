FROM alpine:latest
LABEL Maintainer="Kevin Duane <kevin.duane@disney.com>" \
      Description="Nginx & PHP-FPM based on Alpine Linux."

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-ctype \
    php7-mbstring php7-gd php7-session php7-simplexml php7-pdo_mysql php7-ldap \
    php7-zip php7-imap nginx supervisor curl

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/site.conf /etc/nginx/conf.d/site.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application
RUN rm -rf /var/www/limesurvey
ADD limesurvey.tar.gz /
COPY config/phpinfo.php /limesurvey/phpinfo.php
RUN mv limesurvey /var/www/limesurvey; \
	mkdir -p /uploadstruct; \
    chmod -R 777 /var; \
	chown -R nginx:nginx /var/www

RUN cp -r /var/www/limesurvey/upload/* /uploadstruct/; \
	chown -R nginx:nginx /uploadstruct

RUN chown nginx:nginx /var/lib/php7

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
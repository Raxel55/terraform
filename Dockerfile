FROM php:7.4 AS THEME_BUILDER

WORKDIR /app
COPY ./ /app/

RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - \
 && apt-get update \
 && apt-get install -y nodejs git zip unzip \
 && npm install --global gulp-cli

RUN EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')" \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
    && if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then >&2 echo 'ERROR: Invalid installer checksum' && rm composer-setup.php && exit 1; fi \
    && php composer-setup.php --install-dir=/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN composer update \
    && composer install

#RUN vendor/bin/wp migrate up --interactive=false

RUN cd wp-content/themes/pinboard/ \
 && touch .env \
 && npm ci \
 && gulp build --max-old-space-size=512

FROM wordpress:5.6.2-php7.4

COPY --from=THEME_BUILDER /app /var/www/html

RUN chown -R www-data:www-data /var/www/html

USER www-data

ENV WORDPRESS_DB_HOST "${WORDPRESS_DB_HOST}"
ENV WORDPRESS_DB_USER "${WORDPRESS_DB_USER}"
ENV WORDPRESS_DB_PASSWORD "${WORDPRESS_DB_PASSWORD}"
ENV WORDPRESS_DB_NAME "${WORDPRESS_DB_NAME}"

#RUN ls -la
#RUN npm install gulp
#RUN gulp build

# ENV WP_HOME 0.0.0.0

# ENTRYPOINT cd ./themes/pinboard/ && gulp


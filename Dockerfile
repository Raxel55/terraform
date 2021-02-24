FROM php:7.4

WORKDIR /app
COPY ./[^D]* /app/

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

RUN cd ./themes/pinboard/ \
 && touch .env \
 && npm ci \
 && gulp build --max-old-space-size=512

#RUN ls -la
#RUN npm install gulp
#RUN gulp build

ENV WP_HOME 0.0.0.0

ENTRYPOINT cd ./themes/pinboard/ && gulp

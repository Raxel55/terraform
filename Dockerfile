FROM php:7.4

WORKDIR /app
COPY ./[^D]* /app/

RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - \
 && apt-get update \
 && apt-get install -y nodejs git zip unzip \
 && npm install --global gulp-cli

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'c31c1e292ad7be5f49291169c0ac8f683499edddcfd4e42232982d0fd193004208a58ff6f353fde0012d35fdd72bc394') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN composer update \
    && composer install

#RUN vendor/bin/wp migrate up --interactive=false

RUN cd ./app/themes/pinboard/ \
 && touch .env \
 && npm ci \
 && gulp build --max-old-space-size=512

#RUN ls -la
#RUN npm install gulp
#RUN gulp build

ENV WP_HOME 0.0.0.0

ENTRYPOINT cd ./app/themes/pinboard/ && gulp

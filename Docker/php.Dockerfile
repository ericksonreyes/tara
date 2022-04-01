FROM composer:2.0.12 as build

RUN docker-php-ext-install opcache && docker-php-ext-enable opcache

WORKDIR /usr/local/etc/php/conf.d/

COPY Docker/config/php/php.ini .

WORKDIR /var/www/html

COPY . .

RUN composer --ignore-platform-reqs install --no-dev



FROM php:8.1.1-cli-alpine

RUN apk update && apk add curl git wget

RUN apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS

RUN pecl update-channels

RUN docker-php-ext-install sockets opcache && docker-php-ext-enable opcache

RUN pecl install apcu && docker-php-ext-enable apcu

RUN pecl install pcov && docker-php-ext-enable pcov

RUN apk add --no-cache yaml-dev

RUN pecl channel-update pecl.php.net

RUN pecl install yaml-2.2.2 && docker-php-ext-enable yaml

WORKDIR /usr/local/etc/php/conf.d/

COPY Docker/config/php/php.ini .

WORKDIR /var/www/html

COPY --from=build /var/www/html /var/www/html

ENTRYPOINT [ "php"]
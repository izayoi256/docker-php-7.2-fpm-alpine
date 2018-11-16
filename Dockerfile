FROM php:7.2-fpm-alpine

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN set -x \
    && curl -sS https://getcomposer.org/installer \
    |  php -- \
        --filename=composer \
        --install-dir=/usr/local/bin \
    && apk add --no-cache sudo \
    && sudo -u www-data composer config -g repos.packagist composer https://packagist.jp \
    && sudo -u www-data composer global require --optimize-autoloader hirak/prestissimo

RUN apk add --no-cache --virtual .phpize_deps \
        ${PHPIZE_DEPS} \
        zlib-dev \
    && pecl install \
        apcu \
        xdebug \
    && docker-php-ext-install \
        zip \
    && docker-php-ext-enable \
        xdebug \
        apcu \
    && apk del .phpize_deps \
    && apk add --no-cache \
        git \
        shadow \
        tzdata \
    && rm -rf /tmp/*

COPY ./entrypoint /usr/local/bin/

ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]

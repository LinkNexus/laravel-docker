FROM dunglas/frankenphp:php8.4.11-alpine AS frankenphp_upstream

FROM frankenphp_upstream AS frankenphp_base

WORKDIR /app

RUN apk add --no-cache \
    acl \
    file \
    gettext \
    git \
    supervisor \
    make

RUN set -eux; \
    install-php-extensions \
    @composer \
    apcu \
    intl \
    opcache \
    zip \
    pdo_pgsql \
    pcntl \
    ;

ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

ENV COMPOSER_ALLOW_SUPERUSER=1

ENV PATH="/config/composer/vendor/bin:${PATH}"

COPY --link frankenphp/conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1
CMD ["php", "artisan", "octane:frankenphp"]


# Dev FrankenPHP image
FROM frankenphp_base AS frankenphp_dev

ENV XDEBUG_MODE=off
ENV FRANKENPHP_WORKER_CONFIG=watch

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN set -eux; \
    install-php-extensions \
    xdebug \
    ;

# Installing Nodejs and NPM
RUN apk add nodejs npm

COPY --link frankenphp/conf.d/20-app.dev.ini $PHP_INI_DIR/app.conf.d/

CMD ["php", "artisan", "octane:frankenphp", "--watch"]



# Node build stage
FROM node:lts-alpine AS node_build 

WORKDIR /app

COPY --link package.json package-lock.json ./
RUN npm ci --include=dev

COPY --link . .

RUN npm run build


# Prod FrankenPHP image
FROM frankenphp_base AS frankenphp_prod

ENV APP_ENV=production
ENV APP_DEBUG=false

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --link frankenphp/conf.d/20-app.prod.ini $PHP_INI_DIR/app.conf.d/

COPY --link . ./
RUN set -eux; \
    chmod +x artisan; \
    composer req laragear/preload; \
    composer install --no-cache --prefer-dist --no-dev --no-progress;

RUN rm -rf public/build/
RUN rm -f public/hot
COPY --from=node_build --link /app/public/build /app/public/build
RUN rm -Rf frankenphp/

RUN set -eux; \
    composer dump-autoload --classmap-authoritative --no-dev; \
    [ -f .env ] || cp .env.example .env; \
    php artisan key:generate --ansi; 
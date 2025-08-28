FROM dunglas/frankenphp:php8.4.11-alpine AS frankenphp_upstream

FROM frankenphp_upstream AS frankenphp_base

WORKDIR /app

VOLUME /app/bootstrap/cache

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

COPY --link frankenphp/conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1
CMD ["php", "artisan", "octane:frankenphp"]

# Dev FrankenPHP image
FROM frankenphp_base AS frankenphp_dev

ENV APP_ENV=dev
ENV XDEBUG_MODE=off
ENV FRANKENPHP_WORKER_CONFIG=watch

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN set -eux; \
    install-php-extensions \
    xdebug \
    ;

COPY --link frankenphp/conf.d/20-app.dev.ini $PHP_INI_DIR/app.conf.d/

CMD ["php", "artisan", "octane:frankenphp", "--watch"]
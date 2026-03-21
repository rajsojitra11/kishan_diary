FROM php:8.2-fpm-alpine as base

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    bash git unzip \
    libpq libpq-dev \
    icu-libs icu-dev \
    oniguruma-dev \
    libzip-dev zlib-dev \
    libpng-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring bcmath zip intl xml

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy app files
COPY . .

# Install PHP dependencies only (NO config:cache here — env vars aren't available at build time,
# caching here bakes empty/wrong DB settings and causes 500 errors on first request)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod +x start.sh

# Expose port for Laravel
EXPOSE 8080

# Use www-data user for security
USER www-data

# start.sh: clears stale cache, re-caches with real env vars, runs migrations, starts server
CMD ["bash", "start.sh"]

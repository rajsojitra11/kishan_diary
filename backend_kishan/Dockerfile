FROM php:8.2-fpm-alpine as base

# Install system dependencies and PHP extensions
RUN apk add --no-cache bash git unzip libpq icu-libs icu-dev oniguruma-dev libzip-dev zlib-dev libpng-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring bcmath zip intl xml

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy app files
COPY . .

# Install PHP dependencies (optimized for production)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Expose port for Laravel
EXPOSE 8080

# Use www-data user for security
USER www-data

# Start Laravel with PHP's built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]

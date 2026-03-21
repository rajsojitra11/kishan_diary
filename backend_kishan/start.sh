#!/bin/sh
set -e

echo "=== Kishan Diary API Startup ==="

# Clear stale cached config (was built without real env vars)
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Re-cache with real runtime env vars
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations (safe: --force skips the production prompt)
echo "Running migrations..."
php artisan migrate --force

echo "Starting server on port ${PORT:-8080}..."
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8080}

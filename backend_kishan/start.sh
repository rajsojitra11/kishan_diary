#!/bin/sh
set -e

echo "=== Kishan Diary API Startup ==="

# Clear old cache (important)
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Rebuild cache with correct env
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations (only if DB is ready)
echo "Running migrations..."
php artisan migrate --force || echo "Migration failed, continuing..."

# IMPORTANT: Render uses dynamic PORT (default 10000)
PORT=${PORT:-10000  }

echo "Starting server on port ${PORT}..."
exec php artisan serve --host=0.0.0.0 --port=${PORT}
#!/bin/bash
set -eo pipefail

# Wait for database
echo "Waiting for auth database..."
timeout 30s bash -c 'until nc -z auth-db 5432; do sleep 1; done'

# Run migrations
echo "Running migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start server
echo "Starting auth service..."
exec "$@" 
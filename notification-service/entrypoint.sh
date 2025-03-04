#!/bin/bash
set -eo pipefail

# Wait for database
echo "Waiting for notification database..."
timeout 30s bash -c 'until nc -z notification-db 5432; do sleep 1; done'

# Wait for auth service to be ready
echo "Waiting for auth service..."
timeout 30s bash -c 'until nc -z auth-service 8001; do sleep 1; done'

# Run migrations
echo "Running migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start server
echo "Starting notification service..."
exec "$@" 
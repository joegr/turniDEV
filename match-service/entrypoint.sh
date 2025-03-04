#!/bin/bash
set -eo pipefail

# Wait for database
echo "Waiting for match database..."
timeout 30s bash -c 'until nc -z match-db 5432; do sleep 1; done'

# Wait for auth service to be ready
echo "Waiting for auth service..."
timeout 30s bash -c 'until nc -z auth-service 8001; do sleep 1; done'

# Wait for team service to be ready
echo "Waiting for team service..."
timeout 30s bash -c 'until nc -z team-service 8003; do sleep 1; done'

# Wait for tournament service to be ready
echo "Waiting for tournament service..."
timeout 30s bash -c 'until nc -z tournament-service 8002; do sleep 1; done'

# Run migrations
echo "Running migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start server
echo "Starting match service..."
exec "$@" 
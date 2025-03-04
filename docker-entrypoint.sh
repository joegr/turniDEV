#!/bin/bash
set -eo pipefail

# Wait for postgres with timeout
timeout 30s bash -c 'until nc -z db 5432; do sleep 1; done'

# Run migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start server
exec "$@" 
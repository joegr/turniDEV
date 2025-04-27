#!/bin/bash
set -eo pipefail

# Load common utilities
source /app/common/service_utils.sh

log $LOG_INFO "Starting auth-service..."

# Ensure proper ownership of application files
if [ "$(id -u)" = "0" ]; then
    log $LOG_INFO "Setting proper ownership of application files"
    chown -R appuser:appuser /app/service
fi

# Create Django app structure if it doesn't exist
if [ ! -d "/app/service/auth" ]; then
    log $LOG_INFO "Creating Django app structure"
    
    # Switch to appuser for Django operations
    if [ "$(id -u)" = "0" ]; then
        cd /app/service
        su -c "mkdir -p auth auth/templates auth/static" appuser
        
        # Create basic wsgi.py if it doesn't exist
        if [ ! -f "/app/service/auth/wsgi.py" ]; then
            su -c "cat > auth/wsgi.py << 'EOF'
import os
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'turni_auth.settings')
application = get_wsgi_application()
EOF" appuser
        fi
        
        # Create basic settings.py if it doesn't exist
        if [ ! -f "/app/service/auth/settings.py" ]; then
            su -c "cat > auth/settings.py << 'EOF'
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-key-for-dev')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '*').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'turni_auth.apps.TurniAuthConfig',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'turni_auth.urls'
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'turni_auth.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_DB', 'auth_db'),
        'USER': os.environ.get('POSTGRES_USER', 'postgres'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD', 'postgres'),
        'HOST': os.environ.get('POSTGRES_HOST', 'auth-db'),
        'PORT': os.environ.get('POSTGRES_PORT', '5432'),
    }
}

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
}

# CORS settings
CORS_ALLOW_ALL_ORIGINS = True
EOF" appuser
        fi
        
        # Create basic urls.py if it doesn't exist
        if [ ! -f "/app/service/auth/urls.py" ]; then
            su -c "cat > auth/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

def health_check(request):
    return HttpResponse('OK')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health_check'),
    path('api-auth/', include('rest_framework.urls')),
]
EOF" appuser
        fi
        
        # Create manage.py if it doesn't exist
        if [ ! -f "/app/service/manage.py" ]; then
            su -c "cat > manage.py << 'EOF'
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'turni_auth.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
EOF" appuser
            chmod +x /app/service/manage.py
        fi
    fi
fi

# Wait for database
log $LOG_INFO "Waiting for database..."
wait_for_service auth-db 5432 "auth database" 30 2 || exit 1

# Prepare the Django application
cd /app/service
if [ "$(id -u)" = "0" ]; then
    su -c "python manage.py migrate --noinput" appuser
    su -c "python manage.py collectstatic --noinput" appuser
    
    # Create initial admin user if defined in environment
    if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
        log $LOG_INFO "Creating initial admin user if not exists..."
        su -c "python -c \"
import django
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', 
                                 '$DJANGO_SUPERUSER_EMAIL', 
                                 '$DJANGO_SUPERUSER_PASSWORD')
    print('Superuser created')
else:
    print('Superuser already exists')
\"" appuser
    fi
else
    # If not running as root, run directly
    python manage.py migrate --noinput
    python manage.py collectstatic --noinput
    
    # Create initial admin user if defined in environment
    if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
        log $LOG_INFO "Creating initial admin user if not exists..."
        python -c "
import django
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', 
                                '$DJANGO_SUPERUSER_EMAIL', 
                                '$DJANGO_SUPERUSER_PASSWORD')
    print('Superuser created')
else:
    print('Superuser already exists')
"
    fi
fi

# Create health check endpoint
mkdir -p /tmp/health
echo "OK" > /tmp/health/ok.txt

# Start server
log $LOG_INFO "Starting auth service..."
if [[ "$1" == "runserver" ]]; then
    # Development mode
    if [ "$(id -u)" = "0" ]; then
        log $LOG_INFO "Running in development mode..."
        exec su -c "python manage.py runserver 0.0.0.0:8001" appuser
    else
        exec python manage.py runserver 0.0.0.0:8001
    fi
else
    # Production mode - use gunicorn
    if [ "$(id -u)" = "0" ]; then
        log $LOG_INFO "Running in production mode..."
        exec su -c "gunicorn --bind 0.0.0.0:8001 --workers=2 --threads=4 --timeout=120 auth.wsgi:application" appuser
    else
        # Directly execute the command passed to the script
        log $LOG_INFO "Executing: $@"
        exec "$@"
    fi
fi 
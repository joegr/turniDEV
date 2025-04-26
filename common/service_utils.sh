#!/bin/bash

# Common utility functions for microservice entrypoints
set -eo pipefail

# Configure colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log levels
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3
LOG_DEBUG=4
CURRENT_LOG_LEVEL=${LOG_LEVEL:-1} # Default to INFO

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    if [ "$level" -le "$CURRENT_LOG_LEVEL" ]; then
        case $level in
            1) echo -e "${GREEN}${timestamp} [INFO]${NC} $message" ;;
            2) echo -e "${YELLOW}${timestamp} [WARN]${NC} $message" ;;
            3) echo -e "${RED}${timestamp} [ERROR]${NC} $message" ;;
            4) echo -e "${BLUE}${timestamp} [DEBUG]${NC} $message" ;;
        esac
    fi
}

# Function to get container IP address for fallback
get_container_ip() {
    local container_name=$1
    local ip
    
    # Use getent hosts to try to resolve the hostname
    ip=$(getent hosts "$container_name" | awk '{ print $1 }')
    
    if [ -z "$ip" ]; then
        log $LOG_WARN "Could not resolve $container_name using getent hosts"
        # Try ping as a fallback
        ip=$(ping -c 1 "$container_name" 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fi
    
    echo "$ip"
}

# Function to wait for a service
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    local max_retries=$4
    local retry_interval=$5
    local retry_count=0

    log $LOG_INFO "Waiting for $service_name ($host:$port)..."
    
    # First try with hostname
    until nc -z "$host" "$port" 2>/dev/null || [ $retry_count -eq $max_retries ]; do
        log $LOG_INFO "Attempt $retry_count/$max_retries: Trying hostname $host:$port..."
        
        # After a few attempts, try IP address directly
        if [ $retry_count -gt 5 ]; then
            local ip_addr
            ip_addr=$(get_container_ip "$host")
            
            if [ -n "$ip_addr" ]; then
                log $LOG_INFO "Trying IP address $ip_addr:$port instead of hostname..."
                if nc -z "$ip_addr" "$port" 2>/dev/null; then
                    log $LOG_INFO "Successfully connected to $service_name via IP $ip_addr:$port"
                    return 0
                fi
            fi
        fi
        
        sleep $retry_interval
        retry_count=$((retry_count+1))
    done

    if [ $retry_count -eq $max_retries ]; then
        log $LOG_ERROR "Could not connect to $service_name ($host:$port) after $max_retries attempts"
        return 1
    fi

    log $LOG_INFO "$service_name is available!"
    return 0
}

# Function to prepare Django application
prepare_django_app() {
    local app_name=${1:-$SERVICE_NAME}
    
    log $LOG_INFO "Preparing Django application: $app_name"
    
    # Check if manage.py exists and is executable
    if [ ! -f "manage.py" ]; then
        log $LOG_ERROR "manage.py not found in $(pwd)"
        return 1
    fi
    
    # Create logs directory if it doesn't exist
    mkdir -p logs
    
    log $LOG_INFO "Running migrations..."
    python manage.py migrate --noinput

    log $LOG_INFO "Collecting static files..."
    python manage.py collectstatic --noinput

    # Only create superuser if function exists and DJANGO_SUPERUSER_* env vars are set
    if [ "$(type -t create_superuser)" = "function" ] && [ -n "$DJANGO_SUPERUSER_USERNAME" ]; then
        log $LOG_INFO "Creating superuser if it doesn't exist..."
        create_superuser
    elif [ -f "manage.py" ] && [ -n "$DJANGO_SUPERUSER_USERNAME" ]; then
        log $LOG_INFO "Creating superuser if it doesn't exist..."
        python manage.py createsuperuser --noinput || log $LOG_WARN "Superuser already exists"
    fi

    log $LOG_INFO "Creating health check endpoint..."
    mkdir -p /tmp/health
    echo "OK" > /tmp/health/ok.txt
    
    return 0
}

# Function to start a Django service
start_django_service() {
    local service_name=$1
    local port=${2:-$SERVICE_PORT}
    local workers=${3:-2}
    local threads=${4:-4}
    local timeout=${5:-120}
    
    if [ -z "$port" ]; then
        log $LOG_ERROR "Port must be specified"
        return 1
    fi
    
    log $LOG_INFO "Starting $service_name on port $port with $workers workers..."
    exec gunicorn --bind 0.0.0.0:$port \
        --workers $workers \
        --threads $threads \
        --timeout $timeout \
        --access-logfile - \
        --error-logfile - \
        --log-level info \
        --capture-output \
        --worker-tmp-dir /dev/shm \
        "$service_name.wsgi:application"
}

# Function to create a superuser if it doesn't exist
create_superuser() {
    if [ -z "$DJANGO_SUPERUSER_USERNAME" ] || [ -z "$DJANGO_SUPERUSER_PASSWORD" ]; then
        log $LOG_WARN "DJANGO_SUPERUSER_USERNAME and DJANGO_SUPERUSER_PASSWORD must be set to create a superuser"
        return 1
    fi
    
    log $LOG_INFO "Attempting to create superuser: $DJANGO_SUPERUSER_USERNAME"
    python -c "
import django
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')
    print('Superuser created')
else:
    print('Superuser already exists')
"
} 
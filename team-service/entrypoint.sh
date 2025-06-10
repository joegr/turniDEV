#!/bin/bash
set -eo pipefail

echo "Starting team-service..."

# Source common utilities
if [ -f "/app/common/service_utils.sh" ]; then
    source /app/common/service_utils.sh
else
    echo "Warning: Common utilities not found at /app/common/service_utils.sh"
    # Include fallback functions
    # Function to get container IP address for fallback
    get_container_ip() {
        local container_name=$1
        local ip
        
        # Use sh -c with cat to prevent TTY issues
        ip=$(getent hosts "$container_name" | awk '{ print $1 }')
        
        if [ -z "$ip" ]; then
            echo "Warning: Could not resolve $container_name using getent hosts" >&2
            # Try ping as a fallback
            ip=$(ping -c 1 "$container_name" 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        fi
        
        echo "$ip"
    }

    # Improved function to wait for a service
    wait_for_service() {
        local host=$1
        local port=$2
        local service_name=$3
        local max_retries=$4
        local retry_interval=$5
        local retry_count=0

        echo "Waiting for $service_name ($host:$port)..."
        
        # First try with hostname
        until nc -z "$host" "$port" 2>/dev/null || [ $retry_count -eq $max_retries ]; do
            echo "Attempt $retry_count/$max_retries: Trying hostname $host:$port..."
            
            # After a few attempts, try IP address directly
            if [ $retry_count -gt 5 ]; then
                local ip_addr
                ip_addr=$(get_container_ip "$host")
                
                if [ -n "$ip_addr" ]; then
                    echo "Trying IP address $ip_addr:$port instead of hostname..."
                    if nc -z "$ip_addr" "$port" 2>/dev/null; then
                        echo "Successfully connected to $service_name via IP $ip_addr:$port"
                        return 0
                    fi
                fi
            fi
            
            sleep $retry_interval
            retry_count=$((retry_count+1))
        done

        if [ $retry_count -eq $max_retries ]; then
            echo "Error: Could not connect to $service_name ($host:$port) after $max_retries attempts"
            return 1
        fi

        echo "$service_name is available!"
        return 0
    }
fi

# The dependencies should be handled by docker-compose's dependency management
# We only need to handle fallback in case the Docker dependency checks failed

# Check if critical services are available, with shorter timeouts since Docker should have handled this
if ! nc -z team-db 5432 >/dev/null 2>&1; then
    echo "Warning: team-db not detected, attempting to wait..."
    wait_for_service team-db 5432 "team database" 15 2 || exit 1
fi

# Find manage.py and move to that directory
echo "Locating manage.py..."
MANAGE_PY_LOCATIONS=("/app/manage.py" "/app/service/manage.py")
for location in "${MANAGE_PY_LOCATIONS[@]}"; do
    if [ -f "$location" ]; then
        echo "Found manage.py at $location"
        cd "$(dirname "$location")"
        break
    fi
done

if [ ! -f "manage.py" ]; then
    echo "Error: Could not find manage.py in any expected location"
    exit 1
fi

echo "Working directory: $(pwd)"
echo "Directory contents:"
ls -la

# Prepare the application
echo "Running migrations..."
python manage.py migrate --noinput || true
    
echo "Collecting static files..."
python manage.py collectstatic --noinput || true
    
echo "Creating health check endpoint..."
mkdir -p /tmp/health
echo "OK" > /tmp/health/ok.txt

# Start server
echo "Starting team service..."
if [[ "$1" == "runserver" ]]; then
    # Development mode
    exec python manage.py runserver 0.0.0.0:8003
else
    # Production mode - use gunicorn
    exec "$@"
fi 
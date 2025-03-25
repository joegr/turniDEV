#!/bin/bash

# Common utility functions for microservice entrypoints

# Function to get container IP address for fallback
get_container_ip() {
    local container_name=$1
    local ip
    
    # Use getent hosts to try to resolve the hostname
    ip=$(getent hosts "$container_name" | awk '{ print $1 }')
    
    if [ -z "$ip" ]; then
        echo "Warning: Could not resolve $container_name using getent hosts" >&2
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

# Function to prepare Django application
prepare_django_app() {
    echo "Running migrations..."
    python manage.py migrate --noinput

    echo "Collecting static files..."
    python manage.py collectstatic --noinput

    echo "Creating health check endpoint..."
    mkdir -p /tmp/health
    echo "OK" > /tmp/health/ok.txt
}

# Function to start a Django service
start_django_service() {
    local service_name=$1
    local port=${2:-8000}
    local workers=${3:-4}
    local threads=${4:-2}
    local timeout=${5:-120}
    
    echo "Starting $service_name on port $port with $workers workers..."
    exec gunicorn --bind 0.0.0.0:$port \
        --workers $workers \
        --threads $threads \
        --timeout $timeout \
        --access-logfile - \
        --error-logfile - \
        --log-level info \
        "$service_name.wsgi:application"
} 
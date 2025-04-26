#!/bin/bash
set -eo pipefail

# Get the service port from environment or use default
PORT=${SERVICE_PORT:-8000}
SERVICE_NAME=${SERVICE_NAME:-service}

echo "Running health check for $SERVICE_NAME on port $PORT..."

# Try to connect to the service
if curl -s -f "http://localhost:$PORT/health/" > /dev/null; then
    echo "$SERVICE_NAME health check passed"
    exit 0
else
    echo "$SERVICE_NAME health check failed"
    
    # Get process info for debugging
    echo "Process status:"
    ps aux | grep -E "[p]ython|[g]unicorn"
    
    # Check port availability
    echo "Port status:"
    netstat -tulpn | grep $PORT || echo "Port $PORT not found in netstat"
    
    exit 1
fi 
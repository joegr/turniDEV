#!/bin/bash
set -eo pipefail

# Get the service port from environment or use default
PORT=${SERVICE_PORT:-8000}

# Try to connect to the service
curl -f http://localhost:$PORT/health/ || exit 1 
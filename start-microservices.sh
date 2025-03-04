#!/bin/bash
set -eo pipefail

# Create necessary directories if they don't exist
mkdir -p nginx/conf nginx/certs
mkdir -p services/common
mkdir -p auth-service tournament-service team-service match-service notification-service frontend

# Check if the base image exists
if ! docker image inspect turni-backend-base:latest &> /dev/null; then
    echo "Building backend base image..."
    docker compose build backend-base
fi

# Build and start all services
echo "Building and starting all microservices..."
docker compose up -d

# Show running services
echo "Running services:"
docker compose ps

echo "Microservices are now running!"
echo "Access the application at http://localhost" 
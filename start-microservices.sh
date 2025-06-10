#!/bin/bash
set -eo pipefail

echo "=== Setting up Tournament Microservices ==="

# Create necessary directories if they don't exist
mkdir -p nginx/conf nginx/certs
mkdir -p auth-service tournament-service team-service match-service notification-service frontend
mkdir -p common nginx/certs

# Make sure common utilities are executable
chmod +x common/service_utils.sh

# Always build the backend base image first
echo "Step 1: Building backend base image..."
docker compose --profile build build backend-base

# Clean up any old containers to prevent conflicts
echo "Step 2: Cleaning up any old containers..."
docker compose down -v --remove-orphans

# Start databases first
echo "Step 3: Starting databases..."
docker compose up -d auth-db tournament-db team-db match-db notification-db

# Wait for databases to be ready using docker compose built-in health checks
echo "Step 4: Waiting for databases to be healthy..."
docker compose up -d --wait auth-db tournament-db team-db match-db notification-db

# Start the auth service with wait
echo "Step 5: Starting auth service..."
docker compose up -d --wait auth-service

# Start other backend services in dependency order with wait
echo "Step 6: Starting tournament service..."
docker compose up -d --wait tournament-service

echo "Step 7: Starting team service..."
docker compose up -d --wait team-service

echo "Step 8: Starting match and notification services..."
docker compose up -d --wait match-service notification-service

# Start frontend and nginx
echo "Step 9: Starting frontend and nginx..."
docker compose up -d --wait frontend-service
docker compose up -d --wait nginx

# Show running services
echo "Step 10: Checking service status..."
docker compose ps

echo ""
echo "=== Microservices are now running! ==="
echo "Access the application at http://localhost"
echo ""
echo "Note: The first startup may take a few minutes as databases initialize."
echo "View logs with: docker compose logs -f"
echo ""
echo "To view logs for a specific service:"
echo "docker compose logs -f <service-name>"
echo ""
echo "If you encounter any issues, restart a specific service with:"
echo "docker compose restart <service-name>"
echo ""
echo "For development mode, you can start a service with Django runserver:"
echo "docker compose run <service-name> runserver" 
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

# Wait for databases to be ready
echo "Step 4: Waiting for databases to be healthy..."
sleep 10

# Start the auth service
echo "Step 5: Starting auth service..."
docker compose up -d auth-service

# Wait for auth service to be ready
echo "Step 6: Waiting for auth service to initialize..."
sleep 15

# Start other backend services
echo "Step 7: Starting other backend services..."
docker compose up -d tournament-service team-service match-service notification-service

# Wait for backend services to be ready
echo "Step 8: Waiting for backend services to initialize..."
sleep 15

# Start frontend and nginx
echo "Step 9: Starting frontend and nginx..."
docker compose up -d frontend-service nginx

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
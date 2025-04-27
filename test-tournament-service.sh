#!/bin/bash
set -eo pipefail

echo "=== Setting up Tournament Service Test ==="

# Clean up any old containers
echo "Step 1: Cleaning up any old containers..."
docker compose down -v --remove-orphans

# Start just the tournament database
echo "Step 2: Starting tournament database..."
docker compose up -d tournament-db

# Wait for database to be ready
echo "Step 3: Waiting for database to be healthy..."
sleep 10

# Start the tournament service
echo "Step 4: Starting tournament service..."
docker compose up -d tournament-service

# Wait for tournament service to be ready
echo "Step 5: Waiting for tournament service to initialize..."
sleep 15

# Start frontend 
echo "Step 6: Starting frontend..."
docker compose up -d frontend-service

# Show running services
echo "Step 7: Checking service status..."
docker compose ps

echo ""
echo "=== Test setup complete! ==="
echo "Access the frontend at http://localhost:3000"
echo "Test network connectivity with:"
echo "docker exec frontend-service ping tournament-service"
echo "" 
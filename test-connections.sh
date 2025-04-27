#!/bin/bash
set -eo pipefail

echo "=== Testing Docker Network Connectivity ==="

# Get all containers
echo "Running containers:"
docker ps --format "{{.Names}}"
echo ""

# Create a simple network test container
echo "Creating test container..."
docker run -d --name network-test --network turni_tournament-net alpine sleep 3600

# Test connectivity
echo ""
echo "Testing connectivity from test container:"
echo "-----------------------------------------"

# Function to test connectivity
test_connection() {
  local target=$1
  echo -n "Can resolve $target? "
  if docker exec network-test getent hosts $target &>/dev/null; then
    echo "✅ Yes"
    IP=$(docker exec network-test getent hosts $target | awk '{ print $1 }')
    echo "  IP: $IP"
    
    # If successful, try pinging
    echo -n "Can ping $target? "
    if docker exec network-test ping -c 1 -W 1 $target &>/dev/null; then
      echo "✅ Yes"
    else
      echo "❌ No"
    fi
  else
    echo "❌ No"
  fi
}

# Test all services
for service in auth-service tournament-service tournament-db auth-db frontend-service; do
  test_connection $service
  echo ""
done

# Clean up
echo "Cleaning up test container..."
docker rm -f network-test

echo ""
echo "=== Network testing complete ===" 
#!/bin/bash
set -eo pipefail

# Color configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Turni Microservices - Build, Test, and Deploy ===${NC}"

# Step 1: Build the backend base image
echo -e "${YELLOW}Step 1: Building backend base image...${NC}"
docker compose --profile build build backend-base

# Step 2: Run tests for each service
run_service_tests() {
    local service=$1
    echo -e "${YELLOW}Testing $service...${NC}"
    
    # Create a test container
    docker compose run --rm $service python manage.py test
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $service tests passed${NC}"
        return 0
    else
        echo -e "${RED}✗ $service tests failed${NC}"
        return 1
    fi
}

echo -e "${YELLOW}Step 2: Running tests for each service...${NC}"

# Track if any tests failed
test_failures=0

# Auth Service Tests
echo -e "${BLUE}=== Auth Service Tests ===${NC}"
if run_service_tests auth-service; then
    echo -e "${GREEN}Auth service tests completed successfully${NC}"
else
    echo -e "${RED}Auth service tests failed${NC}"
    test_failures=$((test_failures + 1))
fi

# Tournament Service Tests
echo -e "${BLUE}=== Tournament Service Tests ===${NC}"
if run_service_tests tournament-service; then
    echo -e "${GREEN}Tournament service tests completed successfully${NC}"
else
    echo -e "${RED}Tournament service tests failed${NC}"
    test_failures=$((test_failures + 1))
fi

# Team Service Tests
echo -e "${BLUE}=== Team Service Tests ===${NC}"
if run_service_tests team-service; then
    echo -e "${GREEN}Team service tests completed successfully${NC}"
else
    echo -e "${RED}Team service tests failed${NC}"
    test_failures=$((test_failures + 1))
fi

# Match Service Tests
echo -e "${BLUE}=== Match Service Tests ===${NC}"
if run_service_tests match-service; then
    echo -e "${GREEN}Match service tests completed successfully${NC}"
else
    echo -e "${RED}Match service tests failed${NC}"
    test_failures=$((test_failures + 1))
fi

# Notification Service Tests
echo -e "${BLUE}=== Notification Service Tests ===${NC}"
if run_service_tests notification-service; then
    echo -e "${GREEN}Notification service tests completed successfully${NC}"
else
    echo -e "${RED}Notification service tests failed${NC}"
    test_failures=$((test_failures + 1))
fi

# Step 3: Build and start all services
echo -e "${YELLOW}Step 3: Building and starting all services...${NC}"

# Check if any tests failed
if [ $test_failures -gt 0 ]; then
    echo -e "${RED}WARNING: $test_failures test suites failed${NC}"
    read -p "Do you want to continue with deployment despite test failures? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Deployment aborted due to test failures${NC}"
        exit 1
    fi
fi

# Start all services in the correct order
echo -e "${YELLOW}Starting databases...${NC}"
docker compose up -d auth-db tournament-db team-db match-db notification-db

echo -e "${YELLOW}Waiting for databases to be ready...${NC}"
sleep 10

echo -e "${YELLOW}Starting auth service...${NC}"
docker compose up -d auth-service

echo -e "${YELLOW}Waiting for auth service to be ready...${NC}"
sleep 10

echo -e "${YELLOW}Starting core services...${NC}"
docker compose up -d tournament-service team-service match-service notification-service

echo -e "${YELLOW}Starting frontend and nginx...${NC}"
docker compose up -d frontend-service nginx

# Step 4: Check service status
echo -e "${BLUE}=== Service Status ===${NC}"
docker compose ps

echo -e "${GREEN}=== All services have been built, tested, and started ===${NC}"
echo -e "${GREEN}The application is now accessible at http://localhost${NC}"
echo
echo -e "${BLUE}=== Troubleshooting ===${NC}"
echo -e "- View all logs: ${YELLOW}docker compose logs${NC}"
echo -e "- View service logs: ${YELLOW}docker compose logs [service-name]${NC}"
echo -e "- Restart a service: ${YELLOW}docker compose restart [service-name]${NC}"
echo -e "- Stop all services: ${YELLOW}docker compose down${NC}" 
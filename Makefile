.PHONY: build test start stop restart logs help build-base test-all clean

# Default target
help:
	@echo "Turni Microservices Management"
	@echo ""
	@echo "Usage:"
	@echo "  make build        - Build all services"
	@echo "  make start        - Start all services"
	@echo "  make stop         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make logs         - View logs from all services"
	@echo "  make test-all     - Run tests for all services"
	@echo "  make build-test-run - Build, test, and run all services"
	@echo "  make clean        - Remove all containers and volumes"
	@echo ""
	@echo "Individual services:"
	@echo "  make test-auth    - Run auth service tests"
	@echo "  make test-tournament - Run tournament service tests"
	@echo "  make test-team    - Run team service tests"
	@echo "  make test-match   - Run match service tests"
	@echo "  make test-notification - Run notification service tests"
	@echo ""
	@echo "Service logs:"
	@echo "  make logs-auth    - View auth service logs"
	@echo "  make logs-tournament - View tournament service logs"
	@echo "  make logs-team    - View team service logs"
	@echo "  make logs-match   - View match service logs"
	@echo "  make logs-notification - View notification service logs"
	@echo "  make logs-nginx   - View nginx logs"
	@echo ""

# Build and run
build:
	docker compose build

build-base:
	docker compose --profile build build backend-base

start:
	docker compose up -d

stop:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

build-test-run:
	./build_test_run.sh

# Tests
test-all:
	docker compose run --rm auth-service python manage.py test
	docker compose run --rm tournament-service python manage.py test
	docker compose run --rm team-service python manage.py test
	docker compose run --rm match-service python manage.py test
	docker compose run --rm notification-service python manage.py test

test-auth:
	docker compose run --rm auth-service python manage.py test

test-tournament:
	docker compose run --rm tournament-service python manage.py test

test-team:
	docker compose run --rm team-service python manage.py test

test-match:
	docker compose run --rm match-service python manage.py test

test-notification:
	docker compose run --rm notification-service python manage.py test

# Individual service logs
logs-auth:
	docker compose logs -f auth-service

logs-tournament:
	docker compose logs -f tournament-service

logs-team:
	docker compose logs -f team-service

logs-match:
	docker compose logs -f match-service

logs-notification:
	docker compose logs -f notification-service

logs-nginx:
	docker compose logs -f nginx

# Cleanup
clean:
	docker compose down -v --remove-orphans
	docker volume prune -f 
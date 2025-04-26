# Turni - Tournament Management Platform

Turni is a microservices-based platform for managing gaming tournaments. The platform allows users to create, organize, and participate in tournaments, manage teams, track match results, and receive notifications.

## Architecture

The application is built using a microservices architecture with the following services:

- **Auth Service** - User authentication and authorization (port 8001)
- **Tournament Service** - Tournament management and scheduling (port 8002)
- **Team Service** - Team creation and management (port 8003)
- **Match Service** - Match scheduling and results (port 8004)
- **Notification Service** - Real-time notifications (port 8005)
- **Frontend Service** - React-based user interface (port 80)
- **NGINX** - API Gateway and reverse proxy (ports 80, 443)

Each service has its own database and business logic, communicating with other services via REST APIs.

## Prerequisites

- Docker and Docker Compose
- Git
- Make (optional, for shortcuts)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/yourusername/turni.git
cd turni
```

### Environment Setup

1. Copy the example environment file:

```bash
cp .env.example .env
```

2. Edit the `.env` file and set your desired configurations.

### Build and Run Services

To build and start all services:

```bash
docker compose up -d
```

To build a specific service (e.g., auth-service):

```bash
docker compose up -d auth-service
```

To build all services from scratch:

```bash
docker compose up -d --build
```

### Accessing Services

- Frontend: http://localhost
- API Gateway: http://localhost/api
- Swagger API Documentation: http://localhost/api/docs
- Admin Panel: http://localhost/admin

## Development

### Service Structure

Each service follows a standard structure:

```
service-name/
├── Dockerfile          # Docker configuration
├── entrypoint.sh       # Service startup script
├── requirements.txt    # Python dependencies
└── service/            # Service code
    ├── manage.py       # Django management script
    ├── service_name/   # Service configuration
    │   ├── settings.py # Django settings
    │   ├── urls.py     # URL routing
    │   └── wsgi.py     # WSGI configuration
    └── apps/           # Django applications
```

### Adding a New Service

1. Create a new directory for your service following the structure above
2. Add a Dockerfile and entrypoint.sh based on existing services
3. Add the service to docker-compose.yml
4. Update nginx/conf/default.conf to route to your new service

### Running Tests

Each service has its own test suite. To run tests for a specific service:

```bash
# For example, to run auth-service tests:
docker compose run auth-service python manage.py test
```

Or to run tests for all services:

```bash
docker compose run auth-service python manage.py test
docker compose run tournament-service python manage.py test
docker compose run team-service python manage.py test
docker compose run match-service python manage.py test
docker compose run notification-service python manage.py test
```

## API Documentation

API documentation is available via Swagger UI at http://localhost/api/docs when the application is running.

## Security

- All services run as non-root users
- Communication between services is encrypted
- Authentication is required for all API endpoints (except health checks)

## Monitoring and Troubleshooting

### Logs

View logs for all services:

```bash
docker compose logs
```

For a specific service:

```bash
docker compose logs auth-service
```

Follow logs in real-time:

```bash
docker compose logs -f
```

### Health Checks

Each service exposes a health check endpoint at `/health`. You can check service health with:

```bash
curl http://localhost/api/auth/health/
curl http://localhost/api/tournaments/health/
curl http://localhost/api/teams/health/
curl http://localhost/api/matches/health/
curl http://localhost/api/notifications/health/
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or feedback, please contact the development team at dev@turni.com. 
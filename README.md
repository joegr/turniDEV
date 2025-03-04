# Tournament Management System

A Django-based tournament management system running on Python 3.11.

## Requirements

- Python 3.11+
- PostgreSQL 15+
- Docker and Docker Compose (optional, for containerized setup)

## Environment Setup

1. Create a `.env` file based on the `.env.example` template:
   ```
   cp .env.example .env
   ```

2. Edit the `.env` file and replace placeholder values with actual secure values.

## Local Development Setup

### Using Python 3.11 Virtual Environment

1. Install Python 3.11:
   - **macOS**: Download from [python.org](https://www.python.org/downloads/)
   - **Ubuntu**: `sudo apt update && sudo apt install python3.11 python3.11-venv python3.11-dev`

2. Create and activate a virtual environment:
   ```
   python3.11 -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Run migrations:
   ```
   python manage.py migrate
   ```

5. Start the development server:
   ```
   python manage.py runserver
   ```

### Using Docker

1. Make sure Docker and Docker Compose are installed.

2. Build and start the containers:
   ```
   docker compose up -d
   ```

3. Access the application at `http://localhost:8000`

## Checking Python 3.11 Compatibility

Run the compatibility check script:
```
python check_python311_compatibility.py
```

## Running Tests

```
python manage.py test
```

## Project Structure

- `project/` - Main Django project directory
- `tournament/` - Tournament management app
- `docker-compose.yml` - Docker Compose configuration
- `Dockerfile` - Docker configuration
- `requirements.txt` - Python dependencies

## Upgrading from Python 3.9

If you're upgrading from Python 3.9, run the setup script:
```
./setup_python311_venv.sh
``` 
# Use Python 3.11 as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set service-specific environment variables
ENV SERVICE_PORT=8001

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY ./services/common/requirements.txt /app/common-requirements.txt
COPY ./services/auth-service/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r common-requirements.txt -r requirements.txt

# Copy project
COPY ./services/common /app/common
COPY ./services/auth-service /app

# Run entrypoint script
COPY ./services/auth-service/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Command to run the service
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"] 
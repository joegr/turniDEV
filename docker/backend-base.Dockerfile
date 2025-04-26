FROM python:3.11-slim

LABEL maintainer="DevOps Team <devops@turni.com>"
LABEL description="Base image for Turni microservices"

# Set common environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

# Install common system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    curl \
    netcat-traditional \
    iputils-ping \
    procps \
    htop \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create app user for security (avoid running as root)
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/bash -m appuser

# Create common directories with proper permissions
RUN mkdir -p /app/common /app/static /app/media /app/logs && \
    chown -R appuser:appuser /app

# Install common Python dependencies
COPY --chown=appuser:appuser services/common/requirements.txt /app/common/requirements.txt
RUN pip install --no-cache-dir -r /app/common/requirements.txt

# Copy common health check and utility scripts
COPY --chown=appuser:appuser docker/healthcheck.sh /healthcheck.sh
COPY --chown=appuser:appuser common/service_utils.sh /app/common/service_utils.sh
RUN chmod +x /healthcheck.sh /app/common/service_utils.sh

# Switch to non-root user
USER appuser
WORKDIR /app

# Default health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD ["/healthcheck.sh"] 
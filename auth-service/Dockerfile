FROM turni-backend-base:latest

# Set service-specific environment variables
ENV SERVICE_PORT=8001 \
    SERVICE_NAME=auth \
    DJANGO_SETTINGS_MODULE=auth.settings

# Set working directory for the service
WORKDIR /app/service

# Install service-specific dependencies
COPY --chown=appuser:appuser auth-service/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy service code
COPY --chown=appuser:appuser auth-service/auth /app/service/auth
COPY --chown=appuser:appuser auth-service/manage.py /app/service/manage.py

# Copy service-specific entrypoint
COPY --chown=appuser:appuser auth-service/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create required directories
RUN mkdir -p /app/service/static /app/service/logs /app/service/media \
    && touch /app/service/logs/auth.log

# Add specific health check for this service
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8001/health/ || exit 1

# Switch back to root for entrypoint (which may need to do chown operations)
USER root
ENTRYPOINT ["/entrypoint.sh"]

# Switch back to appuser for running the service
USER appuser
CMD ["gunicorn", "--bind", "0.0.0.0:8001", "--workers=2", "--threads=4", "--timeout=120", "auth.wsgi:application"] 
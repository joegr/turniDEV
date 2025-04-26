FROM turni-backend-base:latest

# Set service-specific environment variables
ENV SERVICE_PORT=8002 \
    SERVICE_NAME=tournament \
    DJANGO_SETTINGS_MODULE=tournament.settings

# Set working directory for the service
WORKDIR /app/service

# Install service-specific dependencies
COPY --chown=appuser:appuser tournament-service/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy service code
COPY --chown=appuser:appuser tournament-service/tournament /app/service/tournament
COPY --chown=appuser:appuser tournament-service/manage.py /app/service/manage.py

# Copy service-specific entrypoint
COPY --chown=appuser:appuser tournament-service/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create required directories
RUN mkdir -p /app/service/static /app/service/logs /app/service/media \
    && touch /app/service/logs/tournament.log

# Add specific health check for this service
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8002/health/ || exit 1

# Switch back to root for entrypoint (which may need to do chown operations)
USER root
ENTRYPOINT ["/entrypoint.sh"]

# Switch back to appuser for running the service
USER appuser
CMD ["gunicorn", "--bind", "0.0.0.0:8002", "--workers=2", "--threads=4", "--timeout=120", "tournament.wsgi:application"] 
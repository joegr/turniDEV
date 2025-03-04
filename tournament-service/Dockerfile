FROM turni-backend-base:latest

# Set service-specific environment variables
ENV SERVICE_PORT=8002 \
    SERVICE_NAME=tournament

# Install service-specific dependencies
COPY tournament-service/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy service code
COPY tournament-service /app/service
WORKDIR /app/service

# Copy service-specific entrypoint
COPY tournament-service/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8002", "tournament.wsgi:application"] 
FROM nginx:latest

# Copy custom nginx configuration
COPY nginx/conf/ /etc/nginx/conf.d/
COPY nginx/certs/ /etc/nginx/certs/

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Expose ports
EXPOSE 80 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"] 
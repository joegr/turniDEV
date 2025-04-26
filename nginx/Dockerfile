FROM nginx:1.25-alpine

# Set environment variables
ENV NGINX_PORT=80 \
    NGINX_HTTPS_PORT=443

# Create directories
RUN mkdir -p /etc/nginx/conf.d /etc/nginx/certs /var/cache/nginx \
    /var/log/nginx /var/run /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx/conf/ /etc/nginx/conf.d/

# Copy SSL certificates if available (or create self-signed for development)
COPY nginx/certs/ /etc/nginx/certs/
RUN if [ ! -f /etc/nginx/certs/server.crt ]; then \
      apk add --no-cache openssl && \
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/certs/server.key \
        -out /etc/nginx/certs/server.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"; \
    fi

# Install dependencies
RUN apk add --no-cache curl ca-certificates wget

# Configure proper permissions
RUN chown -R nginx:nginx /etc/nginx/conf.d /etc/nginx/certs \
    /var/cache/nginx /var/log/nginx /var/run /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Create default health check page
RUN echo "OK" > /usr/share/nginx/html/health && \
    chown nginx:nginx /usr/share/nginx/html/health

# Add health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Expose ports
EXPOSE 80 443

# Switch to non-root user for security
USER nginx

# Start Nginx
CMD ["nginx", "-g", "daemon off;"] 
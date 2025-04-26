## Build stage
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production \
    REACT_APP_API_URL=/api

# Copy package.json files
COPY frontend/package.json frontend/package-lock.json* ./

# Install dependencies
RUN npm ci --production=false

# Copy source code
COPY frontend/src ./src
COPY frontend/public ./public
COPY frontend/tsconfig.json* frontend/.eslintrc* frontend/.babelrc* ./

# Build the app
RUN npm run build

## Production stage
FROM nginx:1.25-alpine

# Set environment variables
ENV NGINX_PORT=80

# Copy build artifacts from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Create required directories
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /usr/share/nginx/html /var/run && \
    chmod -R 755 /usr/share/nginx/html

# Switch to non-root user for security
USER nginx

# Add health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q --spider http://localhost:80/ || exit 1

# Expose port
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"] 
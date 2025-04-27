## Build stage
FROM node:20-alpine as builder

# Set working directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production \
    REACT_APP_API_URL=/api

# Copy package.json files
COPY frontend/package.json ./

# Install dependencies
RUN npm install --production=false

# Copy source code
COPY frontend/src ./src
COPY frontend/public ./public
COPY frontend/tsconfig.json* frontend/.eslintrc* frontend/.babelrc* ./

# Build the app
RUN npm run build

## Production stage
FROM nginx:1.25-alpine as production

# Set environment variables
ENV NGINX_PORT=80

# Copy build artifacts from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Fix permissions issues
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run && \
    chmod -R 777 /var/cache/nginx /var/log/nginx /var/run

# Switch to non-root user for security
USER nginx

# Add health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q --spider http://localhost:80/ || exit 1

# Expose port
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"] 
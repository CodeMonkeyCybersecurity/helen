# Multi-stage build for Hugo website
FROM hugomods/hugo:exts-0.128.0 AS builder

# Set working directory
WORKDIR /src

# Copy Hugo source files
COPY . .

# Install Node.js dependencies
RUN npm ci

# Build CSS and JS assets
RUN npm run build

# Build Hugo site
RUN hugo --minify --gc --environment production

# Production stage
FROM nginx:1.25-alpine

# Install security updates
RUN apk update && apk upgrade && apk add --no-cache \
    curl \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Create nginx user and group
RUN addgroup -g 1001 -S nginx && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copy built website from builder stage
COPY --from=builder /src/public /usr/share/nginx/html

# Copy custom nginx configuration
COPY --from=builder /src/deploy/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /src/deploy/nginx/default.conf /etc/nginx/conf.d/default.conf

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/ssl && \
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /etc/nginx/ssl && \
    chmod 755 /var/log/nginx /var/cache/nginx

# Set proper permissions for web content
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Create health check script
RUN echo '#!/bin/sh' > /usr/local/bin/health-check.sh && \
    echo 'curl -f http://localhost:8080/health || exit 1' >> /usr/local/bin/health-check.sh && \
    chmod +x /usr/local/bin/health-check.sh

# Security hardening
RUN rm -rf /etc/nginx/conf.d/default.conf.bak \
    /usr/share/nginx/html/index.html \
    /usr/share/nginx/html/50x.html

# Add security.txt
RUN mkdir -p /usr/share/nginx/html/.well-known && \
    echo 'Contact: security@cybermonkey.net.au' > /usr/share/nginx/html/.well-known/security.txt && \
    echo 'Expires: 2024-12-31T23:59:59.000Z' >> /usr/share/nginx/html/.well-known/security.txt && \
    echo 'Encryption: https://keybase.io/cybermonkey/pgp_keys.asc' >> /usr/share/nginx/html/.well-known/security.txt && \
    echo 'Preferred-Languages: en' >> /usr/share/nginx/html/.well-known/security.txt && \
    echo 'Canonical: https://cybermonkey.net.au/.well-known/security.txt' >> /usr/share/nginx/html/.well-known/security.txt

# Expose ports
EXPOSE 80 443 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Use nginx user
USER nginx

# Labels for metadata
LABEL maintainer="devops@cybermonkey.net.au" \
      org.opencontainers.image.title="Code Monkey Cybersecurity Website" \
      org.opencontainers.image.description="Hugo-based website for Code Monkey Cybersecurity" \
      org.opencontainers.image.url="https://cybermonkey.net.au" \
      org.opencontainers.image.source="https://github.com/cybermonkey/website" \
      org.opencontainers.image.vendor="Code Monkey Cybersecurity" \
      org.opencontainers.image.licenses="AGPL-3.0"

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
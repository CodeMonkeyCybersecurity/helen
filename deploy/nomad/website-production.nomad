job "cybermonkey-website-production" {
  datacenters = ["australia"]
  region      = "australia"
  type        = "service"
  priority    = 80

  # Specify the version of Nomad required
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  # Update strategy for blue-green deployments
  update {
    max_parallel      = 1
    min_healthy_time  = "30s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    canary            = 1
    auto_promote      = true
  }

  # Migrate strategy
  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "website" {
    count = 3

    # Spread across different availability zones
    spread {
      attribute = "${node.datacenter}"
      weight    = 100
    }

    # Network configuration
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "health" {
        static = 8080
      }
    }

    # Volume for shared assets
    volume "assets" {
      type      = "host"
      read_only = false
      source    = "website-assets"
    }

    # Restart policy
    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    # Ephemeral disk
    ephemeral_disk {
      size = 300
    }

    # Main web server task
    task "nginx" {
      driver = "docker"

      # Volume mount
      volume_mount {
        volume      = "assets"
        destination = "/usr/share/nginx/html/assets"
        read_only   = false
      }

      config {
        image = "nginx:1.25-alpine"
        ports = ["http", "https", "health"]
        
        volumes = [
          "local/nginx.conf:/etc/nginx/nginx.conf",
          "local/default.conf:/etc/nginx/conf.d/default.conf",
          "local/ssl:/etc/nginx/ssl",
          "secrets/ssl_cert.pem:/etc/nginx/ssl/cert.pem",
          "secrets/ssl_key.pem:/etc/nginx/ssl/key.pem",
        ]

        labels = {
          "traefik.enable" = "true"
          "traefik.http.routers.website.rule" = "Host(`cybermonkey.net.au`)"
          "traefik.http.routers.website.tls" = "true"
          "traefik.http.routers.website.tls.certresolver" = "letsencrypt"
          "traefik.http.services.website.loadbalancer.server.port" = "80"
        }
      }

      # Resource requirements
      resources {
        cpu    = 500
        memory = 512
      }

      # Health check
      service {
        name = "cybermonkey-website"
        port = "http"
        
        tags = [
          "production",
          "website",
          "nginx",
          "traefik.enable=true",
          "traefik.http.routers.website.rule=Host(`cybermonkey.net.au`)",
        ]

        check {
          name     = "Website Health"
          type     = "http"
          path     = "/health"
          interval = "30s"
          timeout  = "5s"
          port     = "health"
        }

        check {
          name     = "Website Alive"
          type     = "http"
          path     = "/"
          interval = "60s"
          timeout  = "10s"
          port     = "http"
        }
      }

      # Nginx configuration
      template {
        data = <<EOH
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 16M;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' u.cybermonkey.dev; style-src 'self' 'unsafe-inline' fonts.googleapis.com; img-src 'self' data:; font-src 'self' fonts.gstatic.com; connect-src 'self' u.cybermonkey.dev;" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        image/svg+xml;

    include /etc/nginx/conf.d/*.conf;
}
EOH
        destination = "local/nginx.conf"
      }

      # Virtual host configuration
      template {
        data = <<EOH
server {
    listen 80;
    server_name cybermonkey.net.au www.cybermonkey.net.au;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name cybermonkey.net.au www.cybermonkey.net.au;
    root /usr/share/nginx/html;
    index index.html index.htm;

    # SSL configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Static assets with caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Hugo generated content
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache HTML files for 1 hour
        location ~* \.html$ {
            expires 1h;
            add_header Cache-Control "public, must-revalidate";
        }
    }

    # Security.txt
    location /.well-known/security.txt {
        return 200 "Contact: security@cybermonkey.net.au\nExpires: 2024-12-31T23:59:59.000Z\nEncryption: https://keybase.io/cybermonkey/pgp_keys.asc\nPreferred-Languages: en\nCanonical: https://cybermonkey.net.au/.well-known/security.txt";
        add_header Content-Type text/plain;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOH
        destination = "local/default.conf"
      }

      # SSL certificates from Vault
      template {
        data = <<EOH
{{ with secret "secret/ssl/cybermonkey.net.au" }}
{{ .Data.data.certificate }}
{{ end }}
EOH
        destination = "secrets/ssl_cert.pem"
      }

      template {
        data = <<EOH
{{ with secret "secret/ssl/cybermonkey.net.au" }}
{{ .Data.data.private_key }}
{{ end }}
EOH
        destination = "secrets/ssl_key.pem"
      }

      # Vault configuration
      vault {
        policies = ["cybermonkey-website-production"]
        change_mode = "restart"
      }
    }

    # Hugo site content task
    task "hugo-content" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      config {
        image = "${NOMAD_VAR_container_image}"
        command = "sh"
        args = ["-c", "cp -r /usr/share/nginx/html/* /shared/"]
        
        volumes = [
          "shared:/shared"
        ]
      }

      # Resource requirements
      resources {
        cpu    = 100
        memory = 128
      }

      # Volume mount
      volume_mount {
        volume      = "assets"
        destination = "/shared"
        read_only   = false
      }
    }

    # Log shipping task
    task "log-shipper" {
      driver = "docker"

      config {
        image = "fluent/fluent-bit:latest"
        
        volumes = [
          "local/fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf",
          "/var/log/nginx:/var/log/nginx:ro"
        ]
      }

      # Resource requirements
      resources {
        cpu    = 100
        memory = 128
      }

      # Fluent Bit configuration
      template {
        data = <<EOH
[SERVICE]
    Flush         1
    Log_Level     info
    Daemon        off
    Parsers_File  parsers.conf
    HTTP_Server   On
    HTTP_Listen   0.0.0.0
    HTTP_Port     2020

[INPUT]
    Name              tail
    Path              /var/log/nginx/access.log
    Parser            nginx
    Tag               nginx.access
    Refresh_Interval  5

[INPUT]
    Name              tail
    Path              /var/log/nginx/error.log
    Parser            nginx_error
    Tag               nginx.error
    Refresh_Interval  5

[OUTPUT]
    Name  prometheus_exporter
    Match *
    Host  0.0.0.0
    Port  9090

[OUTPUT]
    Name  cloudwatch_logs
    Match *
    Region ${AWS_REGION}
    Log_Group_Name /nomad/cybermonkey-website-production
    Log_Stream_Name nginx-${NOMAD_ALLOC_ID}
EOH
        destination = "local/fluent-bit.conf"
      }

      # Service registration
      service {
        name = "log-shipper"
        port = "2020"
        
        tags = [
          "logging",
          "fluent-bit",
          "production"
        ]

        check {
          name     = "Fluent Bit Health"
          type     = "http"
          path     = "/api/v1/health"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }

    # Monitoring task
    task "monitoring" {
      driver = "docker"

      config {
        image = "nginx/nginx-prometheus-exporter:latest"
        args = [
          "-nginx.scrape-uri=http://localhost:80/nginx_status",
          "-web.listen-address=:9113"
        ]
        
        ports = ["9113"]
      }

      # Resource requirements
      resources {
        cpu    = 50
        memory = 64
      }

      # Service registration
      service {
        name = "nginx-exporter"
        port = "9113"
        
        tags = [
          "monitoring",
          "prometheus",
          "nginx-exporter"
        ]

        check {
          name     = "Nginx Exporter Health"
          type     = "http"
          path     = "/metrics"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }
}
job "ghost-cms" {
  datacenters = ["dc1"]
  type = "service"

  group "ghost" {
    count = 1

    # Define volume for Ghost data (content + SQLite database)
    volume "ghost-data" {
      type = "host"
      source = "ghost-data"
      read_only = false
    }

    network {
      port "web" {
        static = 8009
        to = 2368
      }
    }

    service {
      name = "ghost-cms"
      port = "web"

      check {
        type     = "http"
        path     = "/ghost/api/admin/site/"
        interval = "30s"
        timeout  = "5s"
      }
    }

    task "ghost" {
      driver = "docker"

      config {
        image = "ghost:5-alpine"
        ports = ["web"]
      }

      # Mount the persistent volume
      volume_mount {
        volume = "ghost-data"
        destination = "/var/lib/ghost/content"
      }

      env {
        # Basic Ghost configuration
        NODE_ENV = "production"
        
        # URL configuration - update this to match your Caddy setup
        url = "https://cybermonkey.net.au"
        
        # Mail configuration for Mailcow
        mail__transport = "SMTP"
        mail__options__host = "${MAIL_HOST}"
        mail__options__port = "${MAIL_PORT}"
        mail__options__secure = "${MAIL_SECURE}"
        mail__from = "${MAIL_FROM}"
      }

      template {
        data = <<EOH
# Mail authentication from Consul
mail__options__auth__user="{{ key "ghost/mail/user" }}"
mail__options__auth__pass="{{ key "ghost/mail/password" }}"
EOH
        destination = "secrets/env"
        env = true
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
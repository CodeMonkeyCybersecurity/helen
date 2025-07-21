job "ghost-cms" {
  datacenters = ["dc1"]
  type = "service"

  group "ghost" {
    count = 1

    network {
      port "web" {
        to = 2368
      }
    }

    service {
      name = "ghost-cms"
      port = "web"
      
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.ghost.rule=Host(`ghost.cybermonkey.net.au`)",
        "traefik.http.routers.ghost.tls=true",
        "traefik.http.routers.ghost.tls.certresolver=letsencrypt"
      ]

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
        
        volumes = [
          "ghost-content:/var/lib/ghost/content"
        ]
      }

      env {
        NODE_ENV = "production"
        database__client = "postgres"
        database__connection__host = "${NOMAD_UPSTREAM_ADDR_postgres}"
        database__connection__database = "ghost"
        database__connection__user = "ghost"
        url = "https://cybermonkey.net.au"
      }

      template {
        data = <<EOH
database__connection__password="{{ key "ghost/db/password" }}"
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

  group "database" {
    count = 1

    network {
      port "db" {
        to = 5432
      }
    }

    service {
      name = "postgres"
      port = "db"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:15-alpine"
        ports = ["db"]
        
        volumes = [
          "postgres-data:/var/lib/postgresql/data"
        ]
      }

      env {
        POSTGRES_DB = "ghost"
        POSTGRES_USER = "ghost"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{ key "ghost/db/password" }}"
EOH
        destination = "secrets/env"
        env = true
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
job "ghost-local" {
  datacenters = ["dc1"]
  type = "service"

  group "ghost" {
    count = 1

    network {
      port "web" {
        static = 8009
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
        
        volumes = [
          "ghost-content:/var/lib/ghost/content"
        ]
      }

      env {
        NODE_ENV = "production"
        database__client = "sqlite3"
        database__connection__filename = "/var/lib/ghost/content/data/ghost.db"
        paths__contentPath = "/var/lib/ghost/content"
        url = "http://localhost:8009"
        admin__url = "http://localhost:8009"
        logging__level = "info"
        logging__transports = "[\"stdout\"]"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
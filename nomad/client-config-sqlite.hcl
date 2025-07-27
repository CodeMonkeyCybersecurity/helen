# Nomad Client Configuration for Ghost with SQLite
# Place this in /etc/nomad.d/client.hcl or include in your Nomad configuration

client {
  enabled = true
  
  # Configure host volume for Ghost data (content + SQLite database)
  host_volume "ghost-data" {
    path = "/opt/nomad/volumes/ghost-data"
    read_only = false
  }
}

# Enable Docker volumes plugin
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
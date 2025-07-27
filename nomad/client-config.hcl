# Nomad Client Configuration with Host Volumes
# This file should be placed in /etc/nomad.d/client.hcl or included in your Nomad client configuration

client {
  enabled = true
  
  # Configure host volumes for persistent storage
  host_volume "ghost-content" {
    path = "/opt/nomad/volumes/ghost-content"
    read_only = false
  }
  
  host_volume "postgres-data" {
    path = "/opt/nomad/volumes/postgres-data"
    read_only = false
  }
}

# Optional: Configure plugin for CSI volumes if needed in the future
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
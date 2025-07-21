# Ubuntu/Nomad Setup Guide

## Quick Start on Ubuntu

### 1. Clone the Repository
```bash
git clone https://github.com/CodeMonkeyCybersecurity/helen.git
cd helen
```

### 2. Install Prerequisites
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Nomad
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install nomad

# Install Consul (for service discovery)
sudo apt install consul

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib
```

### 3. Database Setup
```bash
# Create database and user
sudo -u postgres psql
CREATE DATABASE ghost_production;
CREATE USER ghost WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE ghost_production TO ghost;
\q
```

### 4. Environment Configuration
```bash
# Copy and edit environment file
cp .env.example .env
nano .env
# Update DB_PASSWORD and other credentials
```

### 5. Start Services
```bash
# Start Consul
sudo systemctl start consul
sudo systemctl enable consul

# Start Nomad in dev mode (for testing)
sudo nomad agent -dev

# Or for production:
# sudo systemctl start nomad
# sudo systemctl enable nomad
```

### 6. Deploy with Nomad
```bash
# Deploy Ghost CMS
nomad job run nomad/ghost-cms.nomad

# Check job status
nomad job status ghost-cms

# View logs
nomad alloc logs -f <alloc-id>
```

### 7. Alternative: Docker Compose (Quick Test)
```bash
# For immediate testing without Nomad
docker-compose -f docker-compose-production.yml up -d

# Check logs
docker-compose -f docker-compose-production.yml logs -f
```

## Next Steps

1. Configure SSL/TLS with Let's Encrypt
2. Set up nginx reverse proxy
3. Configure backups
4. Set up monitoring (Prometheus/Grafana)
5. Migrate content from current Ghost instance

## Troubleshooting

- If Nomad fails to start, check: `journalctl -u nomad -f`
- For database connection issues: `sudo -u postgres psql -c "\l"`
- Docker permission issues: Log out and back in after adding to docker group

## Important Files

- `nomad/ghost-cms.nomad` - Nomad job specification
- `docker-compose-production.yml` - Production Docker setup
- `DEPLOYMENT_README.md` - Detailed deployment documentation
- `MIGRATION_STATUS.md` - Current migration issues
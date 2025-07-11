---
title: "Delphi Technical Documentation"
description: "Complete technical documentation for the Delphi Notify platform. Installation guides, API references, and integration instructions."
bookFlatSection: true
weight: 40
---

# Delphi Technical Documentation

Complete technical documentation for the Delphi Notify platform. Installation guides, API references, and integration instructions.

## Documentation Sections

- [Platform Overview](#platform-overview)
- [Installation Guide](#installation-guide)
- [Configuration Reference](#configuration-reference)
- [API Documentation](#api-documentation)
- [Integration Guides](#integration-guides)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)

---

## Platform Overview

### Architecture

Delphi Notify is a cloud-native security monitoring platform that combines automated threat detection with human expert analysis.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client Agent  │───▶│  Delphi Cloud   │───▶│ Expert Analysis │
│                 │    │   Platform      │    │     Center      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ Customer Portal │
                       │   & Alerts      │
                       └─────────────────┘
```

### Key Components

**1. Client Agent**
- Lightweight monitoring agent (< 50MB)
- Real-time threat detection
- Encrypted data transmission
- Automatic updates

**2. Cloud Platform**
- Advanced threat analysis
- Machine learning detection
- Behavioral monitoring
- Threat intelligence integration

**3. Expert Analysis Center**
- Human security experts
- Alert validation and filtering
- Incident response guidance
- Custom threat analysis

**4. Customer Portal**
- Real-time security dashboard
- Alert management
- Reporting and analytics
- Configuration management

### System Requirements

**Minimum Requirements:**
- **Operating System**: Windows 10/11, macOS 10.14+, Ubuntu 18.04+
- **RAM**: 4GB (2GB available)
- **Storage**: 500MB free space
- **Network**: Stable internet connection
- **Privileges**: Administrator/root access for installation

**Recommended Requirements:**
- **RAM**: 8GB+ for optimal performance
- **Storage**: 1GB+ free space for logs
- **Network**: 10Mbps+ for real-time monitoring
- **Backup**: System backup solution in place

---

## Installation Guide

### Windows Installation

**Step 1: Download the Installer**
```powershell
# Download from customer portal or direct link
Invoke-WebRequest -Uri "https://releases.delphi.net/windows/DelphiNotify-Setup.exe" -OutFile "DelphiNotify-Setup.exe"
```

**Step 2: Run Installation**
```powershell
# Run as administrator
Start-Process -FilePath "DelphiNotify-Setup.exe" -ArgumentList "/S" -Verb RunAs
```

**Step 3: Configure Agent**
```powershell
# Configure with your organization token
DelphiNotify.exe --configure --token "your_organization_token"
```

**Step 4: Verify Installation**
```powershell
# Check service status
Get-Service -Name "DelphiNotify" | Select-Object Status, StartType
```

### macOS Installation

**Step 1: Download the Package**
```bash
# Download from customer portal
curl -L "https://releases.delphi.net/macos/DelphiNotify.pkg" -o "DelphiNotify.pkg"
```

**Step 2: Install Package**
```bash
# Install with administrator privileges
sudo installer -pkg DelphiNotify.pkg -target /
```

**Step 3: Configure Agent**
```bash
# Configure with your organization token
sudo delphi-notify --configure --token "your_organization_token"
```

**Step 4: Start Service**
```bash
# Start the service
sudo launchctl load /Library/LaunchDaemons/com.cybermonkey.delphi-notify.plist
```

### Linux Installation

**Step 1: Add Repository**
```bash
# Add Delphi repository
curl -fsSL https://releases.delphi.net/gpg | sudo apt-key add -
echo "deb https://releases.delphi.net/linux/apt stable main" | sudo tee /etc/apt/sources.list.d/delphi.list
```

**Step 2: Install Package**
```bash
# Update package lists and install
sudo apt update
sudo apt install delphi-notify
```

**Step 3: Configure Agent**
```bash
# Configure with your organization token
sudo delphi-notify --configure --token "your_organization_token"
```

**Step 4: Start Service**
```bash
# Enable and start service
sudo systemctl enable delphi-notify
sudo systemctl start delphi-notify
```

### Docker Installation

**Step 1: Pull Image**
```bash
# Pull the latest Delphi Notify image
docker pull delphi/notify:latest
```

**Step 2: Run Container**
```bash
# Run with proper configuration
docker run -d \
  --name delphi-notify \
  --restart unless-stopped \
  --privileged \
  -e DELPHI_TOKEN="your_organization_token" \
  -e DELPHI_HOSTNAME="$(hostname)" \
  -v /var/log:/var/log:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  delphi/notify:latest
```

---

## Configuration Reference

### Agent Configuration

**Configuration file locations:**
- Windows: `C:\ProgramData\DelphiNotify\config.yaml`
- macOS: `/Library/Application Support/DelphiNotify/config.yaml`
- Linux: `/etc/delphi-notify/config.yaml`

**Basic configuration:**
```yaml
# Delphi Notify Agent Configuration
version: "1.0"

# Organization Settings
organization:
  token: "your_organization_token"
  hostname: "unique-hostname"
  tags:
    - "production"
    - "web-server"

# Monitoring Settings
monitoring:
  # File system monitoring
  filesystem:
    enabled: true
    watch_paths:
      - "/var/log"
      - "/etc"
      - "/tmp"
    exclude_paths:
      - "/var/log/archive"
    
  # Network monitoring
  network:
    enabled: true
    monitor_connections: true
    monitor_dns: true
    
  # Process monitoring
  processes:
    enabled: true
    monitor_new_processes: true
    monitor_privilege_escalation: true

# Communication Settings
communication:
  endpoint: "https://api.delphi.net/v1"
  heartbeat_interval: 30
  retry_attempts: 3
  timeout: 10

# Logging Settings
logging:
  level: "INFO"
  file: "/var/log/delphi-notify.log"
  max_size: "100MB"
  max_backups: 5
```

### Advanced Configuration

**Network Configuration:**
```yaml
# Advanced network settings
network:
  proxy:
    enabled: true
    url: "http://proxy.company.com:8080"
    auth:
      username: "proxy_user"
      password: "proxy_password"
  
  ssl:
    verify_certificates: true
    ca_bundle: "/path/to/ca-bundle.pem"
  
  bandwidth:
    limit_mbps: 10
    burst_limit: 20
```

**Alert Configuration:**
```yaml
# Alert settings
alerts:
  # Severity levels: CRITICAL, HIGH, MEDIUM, LOW
  minimum_severity: "MEDIUM"
  
  # Alert delivery methods
  delivery:
    email:
      enabled: true
      addresses:
        - "admin@company.com"
        - "security@company.com"
    
    webhook:
      enabled: true
      url: "https://hooks.company.com/delphi"
      headers:
        Authorization: "Bearer webhook_token"
    
    sms:
      enabled: false
      numbers:
        - "+61432038310"
```

---

## API Documentation

### Authentication

All API requests require authentication using your organization token.

**Authentication Header:**
```
Authorization: Bearer your_organization_token
```

**Base URL:**
```
https://api.delphi.net/v1
```

### Endpoints

#### Get Organization Status
```http
GET /organization/status
```

**Response:**
```json
{
  "organization_id": "org_123456",
  "name": "Your Organization",
  "agents_count": 15,
  "status": "active",
  "plan": "small_business",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

#### List Agents
```http
GET /agents
```

**Query Parameters:**
- `limit` (optional): Number of results (default: 50)
- `offset` (optional): Pagination offset
- `status` (optional): Filter by status (active, inactive, error)

**Response:**
```json
{
  "agents": [
    {
      "agent_id": "agent_789",
      "hostname": "web-server-01",
      "status": "active",
      "last_seen": "2024-01-15T10:25:00Z",
      "version": "1.2.3",
      "tags": ["production", "web-server"]
    }
  ],
  "total": 15,
  "limit": 50,
  "offset": 0
}
```

#### Get Agent Details
```http
GET /agents/{agent_id}
```

**Response:**
```json
{
  "agent_id": "agent_789",
  "hostname": "web-server-01",
  "status": "active",
  "last_seen": "2024-01-15T10:25:00Z",
  "version": "1.2.3",
  "tags": ["production", "web-server"],
  "system_info": {
    "os": "Ubuntu 20.04 LTS",
    "cpu": "Intel Xeon E5-2680 v4",
    "memory": "32GB",
    "disk": "500GB SSD"
  },
  "configuration": {
    "monitoring": {
      "filesystem": true,
      "network": true,
      "processes": true
    }
  }
}
```

#### List Alerts
```http
GET /alerts
```

**Query Parameters:**
- `limit` (optional): Number of results
- `offset` (optional): Pagination offset
- `severity` (optional): Filter by severity
- `status` (optional): Filter by status (open, acknowledged, resolved)
- `start_date` (optional): Filter from date (ISO 8601)
- `end_date` (optional): Filter to date (ISO 8601)

**Response:**
```json
{
  "alerts": [
    {
      "alert_id": "alert_456",
      "severity": "HIGH",
      "status": "open",
      "title": "Suspicious Network Activity Detected",
      "description": "Unusual outbound connections detected from web-server-01",
      "agent_id": "agent_789",
      "hostname": "web-server-01",
      "created_at": "2024-01-15T10:15:00Z",
      "updated_at": "2024-01-15T10:20:00Z",
      "expert_analysis": {
        "reviewed": true,
        "analyst": "Security Expert",
        "summary": "Potential data exfiltration attempt blocked",
        "recommendations": [
          "Review network logs for the past 24 hours",
          "Check for unauthorized software installations",
          "Verify user access credentials"
        ]
      }
    }
  ],
  "total": 23,
  "limit": 50,
  "offset": 0
}
```

#### Acknowledge Alert
```http
POST /alerts/{alert_id}/acknowledge
```

**Request Body:**
```json
{
  "acknowledged_by": "admin@company.com",
  "notes": "Alert reviewed and investigation initiated"
}
```

### Webhook Integration

**Webhook payload format:**
```json
{
  "event": "alert.created",
  "timestamp": "2024-01-15T10:15:00Z",
  "organization_id": "org_123456",
  "data": {
    "alert_id": "alert_456",
    "severity": "HIGH",
    "title": "Suspicious Network Activity Detected",
    "description": "Unusual outbound connections detected from web-server-01",
    "agent_id": "agent_789",
    "hostname": "web-server-01",
    "expert_analysis": {
      "reviewed": true,
      "summary": "Potential data exfiltration attempt blocked",
      "recommendations": [
        "Review network logs for the past 24 hours"
      ]
    }
  }
}
```

**Webhook verification:**
```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    """Verify webhook signature"""
    expected_signature = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected_signature}", signature)
```

---

## Integration Guides

### SIEM Integration

**Splunk Integration:**
```bash
# Install Delphi Notify Add-on for Splunk
# Download from Splunkbase or customer portal
tar -xzf delphi-notify-splunk-addon.tar.gz -C $SPLUNK_HOME/etc/apps/
```

**Configuration:**
```ini
[delphi_notify_input]
interval = 300
sourcetype = delphi:alert
index = security

[delphi_notify_api]
endpoint = https://api.delphi.net/v1
token = your_organization_token
```

**ELK Stack Integration:**
```yaml
# Logstash configuration
input {
  http {
    port => 8080
    codec => json
    type => "delphi_webhook"
  }
}

filter {
  if [type] == "delphi_webhook" {
    mutate {
      add_field => { "source" => "delphi_notify" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "security-alerts-%{+YYYY.MM.dd}"
  }
}
```

### Slack Integration

**Slack App Configuration:**
```json
{
  "webhook_url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
  "channel": "#security-alerts",
  "username": "Delphi Notify",
  "icon_emoji": ":shield:"
}
```

**Custom Slack bot:**
```python
import requests
import json

def send_slack_alert(alert_data):
    webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
    
    message = {
        "text": f"🚨 Security Alert: {alert_data['title']}",
        "attachments": [
            {
                "color": "danger" if alert_data['severity'] == "HIGH" else "warning",
                "fields": [
                    {
                        "title": "Severity",
                        "value": alert_data['severity'],
                        "short": True
                    },
                    {
                        "title": "Host",
                        "value": alert_data['hostname'],
                        "short": True
                    },
                    {
                        "title": "Description",
                        "value": alert_data['description'],
                        "short": False
                    }
                ]
            }
        ]
    }
    
    response = requests.post(webhook_url, json=message)
    return response.status_code == 200
```

### Microsoft Teams Integration

**Teams webhook configuration:**
```python
import requests
import json

def send_teams_alert(alert_data):
    webhook_url = "https://your-tenant.webhook.office.com/webhookb2/YOUR-WEBHOOK-URL"
    
    message = {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": f"Security Alert: {alert_data['title']}",
        "themeColor": "FF0000" if alert_data['severity'] == "HIGH" else "FFA500",
        "sections": [
            {
                "activityTitle": "Delphi Notify Security Alert",
                "activitySubtitle": alert_data['title'],
                "facts": [
                    {
                        "name": "Severity",
                        "value": alert_data['severity']
                    },
                    {
                        "name": "Host",
                        "value": alert_data['hostname']
                    },
                    {
                        "name": "Time",
                        "value": alert_data['created_at']
                    }
                ],
                "text": alert_data['description']
            }
        ]
    }
    
    response = requests.post(webhook_url, json=message)
    return response.status_code == 200
```

---

## Troubleshooting

### Common Issues

**Agent Not Connecting**

*Symptoms:*
- Agent shows "offline" status
- No alerts being generated
- Communication errors in logs

*Solutions:*
1. Check network connectivity
2. Verify organization token
3. Check firewall settings
4. Review proxy configuration

```bash
# Test connectivity
curl -H "Authorization: Bearer your_token" https://api.delphi.net/v1/health

# Check agent logs
tail -f /var/log/delphi-notify.log
```

**High False Positive Rate**

*Symptoms:*
- Too many low-severity alerts
- Alerts for normal system behavior
- Alert fatigue

*Solutions:*
1. Adjust monitoring sensitivity
2. Add exclusions for known good activities
3. Contact support for tuning

```yaml
# Adjust configuration
monitoring:
  sensitivity: "medium"  # Options: low, medium, high
  exclude_processes:
    - "known_good_process"
  exclude_paths:
    - "/path/to/safe/directory"
```

**Performance Issues**

*Symptoms:*
- System slowdown
- High CPU usage
- Memory consumption

*Solutions:*
1. Check system resources
2. Adjust monitoring scope
3. Review log rotation

```bash
# Check resource usage
top -p $(pgrep delphi-notify)

# Adjust configuration
monitoring:
  filesystem:
    scan_interval: 300  # Increase interval
    exclude_paths:
      - "/large/directory"  # Exclude large directories
```

### Log Analysis

**Log Levels:**
- `ERROR`: System errors requiring attention
- `WARN`: Warnings about potential issues
- `INFO`: General information about operations
- `DEBUG`: Detailed debugging information

**Important log patterns:**
```bash
# Connection issues
grep "connection" /var/log/delphi-notify.log

# Authentication problems
grep "auth" /var/log/delphi-notify.log

# Performance issues
grep "timeout\|slow" /var/log/delphi-notify.log
```

### Support Resources

**Getting Help:**
- **Email**: support@cybermonkey.net.au
- **Phone**: (+61) 0432 038 310
- **Customer Portal**: https://portal.delphi.net
- **Documentation**: https://docs.delphi.net

**Information to Include:**
- Agent version and operating system
- Relevant log entries
- Configuration files (with tokens removed)
- Steps to reproduce the issue

---

## Security Best Practices

### Agent Security

**1. Regular Updates**
```bash
# Enable automatic updates
delphi-notify --configure --auto-update=true

# Manual update check
delphi-notify --update --check
```

**2. Secure Configuration**
```yaml
# Use secure settings
communication:
  ssl:
    verify_certificates: true
    min_tls_version: "1.2"
  
  encryption:
    enabled: true
    algorithm: "AES-256-GCM"
```

**3. Access Control**
```bash
# Set proper file permissions
sudo chmod 600 /etc/delphi-notify/config.yaml
sudo chown root:root /etc/delphi-notify/config.yaml
```

### Network Security

**Required Network Access:**
- `api.delphi.net:443` (HTTPS)
- `updates.delphi.net:443` (HTTPS)
- `telemetry.delphi.net:443` (HTTPS)

**Firewall Configuration:**
```bash
# Allow outbound connections
sudo ufw allow out 443/tcp
sudo ufw allow out 80/tcp  # For initial setup only
```

### Monitoring Security

**1. Log Security**
```bash
# Secure log files
sudo chmod 640 /var/log/delphi-notify.log
sudo chown root:adm /var/log/delphi-notify.log
```

**2. Configuration Management**
```yaml
# Use environment variables for sensitive data
organization:
  token: "${DELPHI_TOKEN}"
  
# Rotate tokens regularly
communication:
  token_rotation:
    enabled: true
    interval: "30d"
```

**3. Incident Response**
```yaml
# Configure incident response
alerts:
  incident_response:
    enabled: true
    escalation_rules:
      - severity: "CRITICAL"
        notify_immediately: true
        contacts:
          - "security@company.com"
          - "+61432038310"
```

---

## API Rate Limits

**Current Limits:**
- `GET /alerts`: 100 requests per minute
- `GET /agents`: 50 requests per minute
- `POST /alerts/{id}/acknowledge`: 20 requests per minute
- `GET /organization/status`: 10 requests per minute

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248000
```

**Handling Rate Limits:**
```python
import time
import requests

def api_request_with_retry(url, headers, max_retries=3):
    for attempt in range(max_retries):
        response = requests.get(url, headers=headers)
        
        if response.status_code == 429:
            reset_time = int(response.headers.get('X-RateLimit-Reset', 0))
            sleep_time = reset_time - int(time.time()) + 1
            time.sleep(max(sleep_time, 1))
            continue
            
        return response
    
    raise Exception("Max retries exceeded")
```

---

*This documentation is updated regularly. For the latest version, visit the [customer portal](https://portal.delphi.net) or contact [support](mailto:support@cybermonkey.net.au).*
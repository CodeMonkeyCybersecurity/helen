job "monitoring-stack" {
  datacenters = ["australia"]
  region      = "australia"
  type        = "service"
  priority    = 70

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  # Prometheus group
  group "prometheus" {
    count = 1

    network {
      port "prometheus" {
        static = 9090
      }
    }

    volume "prometheus_data" {
      type      = "host"
      read_only = false
      source    = "prometheus-data"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:latest"
        ports = ["prometheus"]
        
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/etc/prometheus/console_libraries",
          "--web.console.templates=/etc/prometheus/consoles",
          "--web.enable-lifecycle",
          "--storage.tsdb.retention.time=30d",
          "--storage.tsdb.retention.size=10GB"
        ]

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "local/alerts.yml:/etc/prometheus/alerts.yml",
        ]
      }

      volume_mount {
        volume      = "prometheus_data"
        destination = "/prometheus"
        read_only   = false
      }

      template {
        data = <<EOH
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'cybermonkey-${NOMAD_META_environment}'
    region: '${NOMAD_DC}'

rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager.service.consul:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'nomad'
    consul_sd_configs:
      - server: '{{ env "CONSUL_HTTP_ADDR" | default "localhost:8500" }}'
        services: ['nomad']
    relabel_configs:
      - source_labels: [__meta_consul_service_port]
        target_label: __address__
        replacement: '${1}:4646'

  - job_name: 'consul'
    consul_sd_configs:
      - server: '{{ env "CONSUL_HTTP_ADDR" | default "localhost:8500" }}'
        services: ['consul']
    relabel_configs:
      - source_labels: [__meta_consul_service_port]
        target_label: __address__
        replacement: '${1}:8500'

  - job_name: 'vault'
    consul_sd_configs:
      - server: '{{ env "CONSUL_HTTP_ADDR" | default "localhost:8500" }}'
        services: ['vault']
    relabel_configs:
      - source_labels: [__meta_consul_service_port]
        target_label: __address__
        replacement: '${1}:8200'

  - job_name: 'website'
    consul_sd_configs:
      - server: '{{ env "CONSUL_HTTP_ADDR" | default "localhost:8500" }}'
        services: ['cybermonkey-website']
    metrics_path: /metrics
    relabel_configs:
      - source_labels: [__meta_consul_service_port]
        target_label: __address__
        replacement: '${1}:9113'

  - job_name: 'node-exporter'
    consul_sd_configs:
      - server: '{{ env "CONSUL_HTTP_ADDR" | default "localhost:8500" }}'
        services: ['node-exporter']

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://cybermonkey.net.au
        - https://staging.cybermonkey.net.au
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter.service.consul:9115
EOH
        destination = "local/prometheus.yml"
      }

      template {
        data = <<EOH
groups:
  - name: website
    rules:
      - alert: WebsiteDown
        expr: up{job="website"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Website is down"
          description: "Website has been down for more than 1 minute"

      - alert: HighErrorRate
        expr: rate(nginx_http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} requests/sec"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(nginx_http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ $value }} seconds"

  - name: infrastructure
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}%"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"}) * 100 < 20
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space"
          description: "Disk space is {{ $value }}% full"

  - name: nomad
    rules:
      - alert: NomadNodeDown
        expr: up{job="nomad"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Nomad node is down"
          description: "Nomad node has been down for more than 2 minutes"

      - alert: NomadJobFailed
        expr: nomad_nomad_job_summary_failed > 0
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Nomad job failed"
          description: "{{ $value }} Nomad jobs have failed"
EOH
        destination = "local/alerts.yml"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "prometheus"
        port = "prometheus"
        
        tags = [
          "monitoring",
          "prometheus",
          "metrics"
        ]

        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }

  # Grafana group
  group "grafana" {
    count = 1

    network {
      port "grafana" {
        static = 3000
      }
    }

    volume "grafana_data" {
      type      = "host"
      read_only = false
      source    = "grafana-data"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:latest"
        ports = ["grafana"]
        
        volumes = [
          "local/grafana.ini:/etc/grafana/grafana.ini",
          "local/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml",
          "local/dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yml",
        ]
      }

      volume_mount {
        volume      = "grafana_data"
        destination = "/var/lib/grafana"
        read_only   = false
      }

      template {
        data = <<EOH
[DEFAULT]
instance_name = grafana-${NOMAD_META_environment}

[server]
protocol = http
http_addr = 0.0.0.0
http_port = 3000
root_url = https://grafana.cybermonkey.net.au

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db

[session]
provider = file
provider_config = /var/lib/grafana/sessions

[security]
admin_user = admin
admin_password = {{ key "grafana/admin_password" }}
secret_key = {{ key "grafana/secret_key" }}

[users]
allow_sign_up = false
allow_org_create = false
auto_assign_org = true
auto_assign_org_role = Viewer

[auth.anonymous]
enabled = false

[log]
mode = console
level = info

[alerting]
enabled = true
execute_alerts = true

[metrics]
enabled = true

[tracing.jaeger]
address = jaeger.service.consul:14268
EOH
        destination = "local/grafana.ini"
      }

      template {
        data = <<EOH
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus.service.consul:9090
    isDefault: true
    editable: true

  - name: Loki
    type: loki
    access: proxy
    url: http://loki.service.consul:3100
    editable: true

  - name: Jaeger
    type: jaeger
    access: proxy
    url: http://jaeger.service.consul:16686
    editable: true
EOH
        destination = "local/datasources.yml"
      }

      template {
        data = <<EOH
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOH
        destination = "local/dashboards.yml"
      }

      resources {
        cpu    = 300
        memory = 512
      }

      service {
        name = "grafana"
        port = "grafana"
        
        tags = [
          "monitoring",
          "grafana",
          "dashboard"
        ]

        check {
          type     = "http"
          path     = "/api/health"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }

  # Alertmanager group
  group "alertmanager" {
    count = 1

    network {
      port "alertmanager" {
        static = 9093
      }
    }

    volume "alertmanager_data" {
      type      = "host"
      read_only = false
      source    = "alertmanager-data"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "alertmanager" {
      driver = "docker"

      config {
        image = "prom/alertmanager:latest"
        ports = ["alertmanager"]
        
        args = [
          "--config.file=/etc/alertmanager/alertmanager.yml",
          "--storage.path=/alertmanager",
          "--web.external-url=https://alertmanager.cybermonkey.net.au",
          "--cluster.advertise-address=0.0.0.0:9093"
        ]

        volumes = [
          "local/alertmanager.yml:/etc/alertmanager/alertmanager.yml",
        ]
      }

      volume_mount {
        volume      = "alertmanager_data"
        destination = "/alertmanager"
        read_only   = false
      }

      template {
        data = <<EOH
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@cybermonkey.net.au'
  smtp_auth_username: '{{ key "alertmanager/smtp_username" }}'
  smtp_auth_password: '{{ key "alertmanager/smtp_password" }}'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: 'critical'
    - match:
        severity: warning
      receiver: 'warning'

receivers:
  - name: 'default'
    email_configs:
      - to: 'devops@cybermonkey.net.au'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

  - name: 'critical'
    email_configs:
      - to: 'devops@cybermonkey.net.au'
        subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          CRITICAL Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    slack_configs:
      - api_url: '{{ key "alertmanager/slack_webhook" }}'
        channel: '#alerts'
        title: 'CRITICAL: {{ .GroupLabels.alertname }}'
        text: |
          {{ range .Alerts }}
          {{ .Annotations.summary }}
          {{ .Annotations.description }}
          {{ end }}

  - name: 'warning'
    email_configs:
      - to: 'devops@cybermonkey.net.au'
        subject: 'WARNING: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Warning: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOH
        destination = "local/alertmanager.yml"
      }

      resources {
        cpu    = 100
        memory = 256
      }

      service {
        name = "alertmanager"
        port = "alertmanager"
        
        tags = [
          "monitoring",
          "alertmanager",
          "alerts"
        ]

        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }

  # Blackbox exporter group
  group "blackbox-exporter" {
    count = 1

    network {
      port "blackbox" {
        static = 9115
      }
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "blackbox-exporter" {
      driver = "docker"

      config {
        image = "prom/blackbox-exporter:latest"
        ports = ["blackbox"]
        
        args = [
          "--config.file=/etc/blackbox_exporter/config.yml"
        ]

        volumes = [
          "local/blackbox.yml:/etc/blackbox_exporter/config.yml",
        ]
      }

      template {
        data = <<EOH
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: [200]
      method: GET
      follow_redirects: true
      fail_if_ssl: false
      fail_if_not_ssl: true
      
  http_post_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: [200]
      method: POST
      
  tcp_connect:
    prober: tcp
    timeout: 5s
    
  icmp:
    prober: icmp
    timeout: 5s
EOH
        destination = "local/blackbox.yml"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "blackbox-exporter"
        port = "blackbox"
        
        tags = [
          "monitoring",
          "blackbox",
          "uptime"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }
}
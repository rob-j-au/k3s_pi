# K3s Home Lab Setup for Raspberry Pi

A complete Kubernetes (K3s) setup for running a home lab on Raspberry Pi, featuring monitoring, home automation, and networking services.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Services](#services)
- [Configuration](#configuration)
- [Secrets Setup](#secrets-setup)
- [Management](#management)
- [Troubleshooting](#troubleshooting)
- [Architecture](#architecture)

## 🎯 Overview

This repository contains Kubernetes manifests for deploying a complete home lab stack on a Raspberry Pi using K3s. All services are configured to use host networking for easy access and persistent storage for data retention.

### Features

- 🏠 **Home Automation** - Home Assistant with Zigbee support
- 📊 **Monitoring Stack** - Prometheus, Grafana, InfluxDB, Loki
- 🌐 **Networking** - Cloudflare DDNS, Squid proxy, mDNS aliases
- 🔧 **Easy Management** - Simple kubectl commands
- 💾 **Persistent Storage** - All data persisted to host volumes
- 🔒 **Secrets Management** - Kubernetes secrets for sensitive data

## 📦 Prerequisites

### Hardware

- Raspberry Pi 4 (4GB+ RAM recommended)
- MicroSD card (32GB+ recommended)
- (Optional) Zigbee USB dongle for Home Assistant

### Software

- Raspberry Pi OS (64-bit recommended)
- Internet connection

## 🚀 Quick Start

### 1. Clone this repository

```bash
git clone <your-repo-url>
cd k3s
```

### 2. Install K3s

```bash
sudo bash install-k3s.sh
```

This will:
- Install K3s lightweight Kubernetes
- Configure kubectl access
- Set up the `pi-services` namespace

### 3. Create Required Secrets

Before deploying services, create the necessary secrets and config maps:

```bash
# Cloudflare API Token (for DDNS)
kubectl create secret generic cloudflare-secret \
  -n pi-services \
  --from-literal=CF_API_TOKEN=your_cloudflare_api_token_here

# Cloudflare Domain
kubectl create configmap cloudflare-config \
  -n pi-services \
  --from-literal=domain=your.domain.com

# Grafana Admin Password
kubectl create secret generic grafana-secret \
  -n pi-services \
  --from-literal=admin-password=your_secure_password_here
```

### 4. Deploy All Services

```bash
sudo bash deploy-all.sh
```

### 5. Verify Deployment

```bash
kubectl get pods -n pi-services
```

All pods should show `Running` status within a few minutes.

## 🛠️ Services

| Service | Port | Description | Image |
|---------|------|-------------|-------|
| **Home Assistant** | 8123 | Home automation platform | `ghcr.io/home-assistant/home-assistant:stable` |
| **Grafana** | 3000 | Metrics visualization dashboards | `grafana/grafana:latest` |
| **Prometheus** | 9090 | Metrics collection and storage | `prom/prometheus:latest` |
| **InfluxDB** | 8086 | Time-series database | `influxdb:2.7` |
| **Loki** | 3100 | Log aggregation system | `grafana/loki:latest` |
| **Promtail** | 9080 | Log collector for Loki | `grafana/promtail:latest` |
| **Telegraf** | - | Metrics collector agent | `telegraf:latest` |
| **Squid** | 3128 | HTTP/HTTPS proxy cache | `ubuntu/squid:latest` |
| **Cloudflare DDNS** | - | Dynamic DNS updater | `favonia/cloudflare-ddns:latest` |
| **go-avahi-cname** | - | mDNS CNAME aliases | `ghcr.io/grishy/go-avahi-cname:v2.0.3` |
| **Matter Server** | 5580 | Matter smart home protocol | `ghcr.io/home-assistant-libs/python-matter-server:stable` |

### Service Access

After deployment, access services at:

- **Home Assistant**: `http://pi.local:8123`
- **Grafana**: `http://pi.local:3000`
- **Prometheus**: `http://pi.local:9090`
- **InfluxDB**: `http://pi.local:8086`

## ⚙️ Configuration

### Volume Paths

All services use persistent volumes stored on the host:

```
/kubernetes-volumes/
├── homeassistant/
├── grafana/
├── prometheus/
├── influxdb/
├── loki/
└── matter-server/
```

### Configuration Files

Additional configuration files are stored in:

```
/opt/k3s-config/
├── grafana/provisioning/
├── prometheus/
└── loki/
```

### Home Assistant Specific

Home Assistant requires:
- Zigbee USB dongle at `/dev/ttyACM0`
- D-Bus access for Bluetooth
- Scripts directory at `/opt/scripts`

## 🔐 Secrets Setup

This repository uses Kubernetes Secrets and ConfigMaps for sensitive data. You must create these before deploying:

### Required Secrets

#### 1. Cloudflare Secret

For dynamic DNS updates:

```bash
kubectl create secret generic cloudflare-secret \
  -n pi-services \
  --from-literal=CF_API_TOKEN=<your-cloudflare-api-token>
```

**How to get a Cloudflare API Token:**
1. Log in to Cloudflare Dashboard
2. Go to My Profile → API Tokens
3. Create Token → Edit zone DNS template
4. Select your zone and create token

#### 2. Cloudflare ConfigMap

Your domain name:

```bash
kubectl create configmap cloudflare-config \
  -n pi-services \
  --from-literal=domain=<your.domain.com>
```

#### 3. Grafana Secret

Admin password for Grafana:

```bash
kubectl create secret generic grafana-secret \
  -n pi-services \
  --from-literal=admin-password=<your-password>
```

### Verify Secrets

```bash
kubectl get secrets -n pi-services
kubectl get configmaps -n pi-services
```

## 🎮 Management

### View All Pods

```bash
kubectl get pods -n pi-services
```

### View Pod Logs

```bash
# Follow logs in real-time
kubectl logs -f deployment/homeassistant -n pi-services

# View last 100 lines
kubectl logs --tail=100 deployment/grafana -n pi-services
```

### Restart a Service

```bash
kubectl rollout restart deployment/homeassistant -n pi-services
```

### Shell into a Container

```bash
kubectl exec -it deployment/homeassistant -n pi-services -- bash
```

### Update a Service

```bash
# Edit the manifest
vim manifests/homeassistant.yaml

# Apply changes
kubectl apply -f manifests/homeassistant.yaml
```

### Delete and Recreate

```bash
kubectl delete deployment homeassistant -n pi-services
kubectl apply -f manifests/homeassistant.yaml
```

### Scale a Deployment

```bash
kubectl scale deployment/grafana --replicas=0 -n pi-services  # Stop
kubectl scale deployment/grafana --replicas=1 -n pi-services  # Start
```

## 🔧 Troubleshooting

### Pod Won't Start

```bash
# Check pod status
kubectl describe pod <pod-name> -n pi-services

# Check events
kubectl get events -n pi-services --sort-by='.lastTimestamp'
```

### Service Not Accessible

```bash
# Check if pod is running
kubectl get pods -n pi-services

# Check service
kubectl get svc -n pi-services

# Verify host network
kubectl get pod <pod-name> -n pi-services -o yaml | grep hostNetwork
```

### Volume Permission Issues

```bash
# Fix permissions on host
sudo chown -R 1000:1000 /kubernetes-volumes/<service-name>
```

### Home Assistant Zigbee Issues

```bash
# Verify USB device
ls -la /dev/ttyACM0

# Check device permissions
sudo chmod 666 /dev/ttyACM0
```

### View All Resources

```bash
kubectl get all -n pi-services
```

## 🏗️ Architecture

### Network Architecture

All services use `hostNetwork: true` for:
- Direct access to host network interfaces
- No port mapping required
- Simplified networking
- Better performance

### Storage Architecture

- **hostPath volumes** for persistent data
- Data survives pod restarts
- Easy backup (just backup `/kubernetes-volumes/`)

### Security Considerations

- Secrets stored in Kubernetes (not in manifests)
- ConfigMaps for non-sensitive configuration
- Privileged containers only where needed (Home Assistant, Telegraf)
- Network isolation via namespace

## 📝 Customization

### Adding a New Service

1. Create a manifest in `manifests/`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
  namespace: pi-services
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-service
  template:
    metadata:
      labels:
        app: my-service
    spec:
      hostNetwork: true
      containers:
      - name: my-service
        image: my-image:latest
        # ... rest of config
```

2. Apply it:

```bash
kubectl apply -f manifests/my-service.yaml
```

### Modifying Resource Limits

Edit the manifest and adjust:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

## 🤝 Contributing

Feel free to submit issues and pull requests!

## 📄 License

MIT License - feel free to use this for your own home lab!

## 🙏 Acknowledgments

- [K3s](https://k3s.io/) - Lightweight Kubernetes
- [Home Assistant](https://www.home-assistant.io/) - Home automation
- [Grafana Labs](https://grafana.com/) - Monitoring stack
- All the amazing open-source projects used in this setup

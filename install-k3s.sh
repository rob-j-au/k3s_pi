#!/bin/bash
set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "=== Installing K3s on Pi ==="

# Install K3s with Docker backend (uses existing Docker)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker --disable=traefik --write-kubeconfig-mode=644" sh -

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
sleep 10
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# Create symlink for kubectl config
mkdir -p ~/.kube
ln -sf /etc/rancher/k3s/k3s.yaml ~/.kube/config

echo "=== K3s installed successfully ==="
kubectl get nodes

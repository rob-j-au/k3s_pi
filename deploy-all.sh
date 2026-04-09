#!/bin/bash
set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Deploying all services to K3s ==="

# Apply namespace first
kubectl apply -f "$SCRIPT_DIR/manifests/namespace.yaml"

# Apply all manifests
for manifest in "$SCRIPT_DIR/manifests"/*.yaml; do
    echo "Applying: $(basename "$manifest")"
    kubectl apply -f "$manifest"
done

echo ""
echo "=== Waiting for deployments to be ready ==="
kubectl -n pi-services wait --for=condition=Available deployment --all --timeout=300s || true

echo ""
echo "=== Deployment status ==="
kubectl -n pi-services get deployments
kubectl -n pi-services get pods

echo ""
echo "=== Services ==="
kubectl -n pi-services get services

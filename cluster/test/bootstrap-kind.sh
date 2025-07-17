#!/usr/bin/env bash
set -aeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLUSTER_NAME="provider-backblaze-testing"

echo "=== Bootstrapping Kind cluster for Backblaze provider testing ==="

# Check if Kind is installed
if ! command -v kind &> /dev/null; then
    echo "Kind not found. Installing Kind..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install kind
        else
            echo "Please install Kind manually: https://kind.sigs.k8s.io/docs/user/quick-start/"
            exit 1
        fi
    else
        echo "Please install Kind manually: https://kind.sigs.k8s.io/docs/user/quick-start/"
        exit 1
    fi
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl."
    exit 1
fi

# Create Kind cluster
echo "Creating Kind cluster: ${CLUSTER_NAME}"
kind create cluster --config="${PROJECT_ROOT}/cluster/kind-config.yaml" --name="${CLUSTER_NAME}"

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install Crossplane
echo "Installing Crossplane..."
kubectl create namespace crossplane-system || true
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace \
    --wait

# Wait for Crossplane to be ready
echo "Waiting for Crossplane to be ready..."
kubectl wait --for=condition=Available deployment/crossplane --namespace=crossplane-system --timeout=300s

# Create upbound-system namespace for provider
echo "Creating upbound-system namespace..."
kubectl create namespace upbound-system || true

echo "=== Kind cluster bootstrap complete ==="
echo "Cluster name: ${CLUSTER_NAME}"
echo "To use this cluster:"
echo "  kubectl config use-context kind-${CLUSTER_NAME}"
echo ""
echo "To install the provider:"
echo "  make local-deploy"
echo ""
echo "To delete the cluster:"
echo "  kind delete cluster --name ${CLUSTER_NAME}"
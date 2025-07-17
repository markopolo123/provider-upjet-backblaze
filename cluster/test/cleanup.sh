#!/usr/bin/env bash
set -aeuo pipefail

CLUSTER_NAME="provider-backblaze-testing"

echo "=== Cleaning up Kind cluster ==="

# Check if cluster exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Deleting Kind cluster: ${CLUSTER_NAME}"
    kind delete cluster --name="${CLUSTER_NAME}"
    echo "Cluster deleted successfully"
else
    echo "Cluster ${CLUSTER_NAME} not found"
fi

# Clean up any leftover contexts
kubectl config delete-context "kind-${CLUSTER_NAME}" 2>/dev/null || true

echo "=== Cleanup complete ==="
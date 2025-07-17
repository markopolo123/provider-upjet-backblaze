#!/usr/bin/env bash
set -aeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "=== Testing Backblaze Provider ==="

# Check required environment variables
if [[ -z "${B2_APPLICATION_KEY_ID:-}" || -z "${B2_APPLICATION_KEY:-}" ]]; then
    echo "Error: B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY environment variables must be set"
    echo "Please set these with your Backblaze B2 credentials:"
    echo "  export B2_APPLICATION_KEY_ID=your_key_id"
    echo "  export B2_APPLICATION_KEY=your_key"
    exit 1
fi

# Create test namespace
echo "Creating test namespace..."
kubectl create namespace backblaze-test || true

# Create secret with credentials
echo "Creating Backblaze credentials secret..."
kubectl -n upbound-system create secret generic provider-secret \
    --from-literal=credentials="{\"application_key_id\":\"${B2_APPLICATION_KEY_ID}\",\"application_key\":\"${B2_APPLICATION_KEY}\"}" \
    --dry-run=client -o yaml | kubectl apply -f -

# Apply provider config
echo "Applying ProviderConfig..."
kubectl apply -f "${PROJECT_ROOT}/examples/providerconfig/providerconfig.yaml"

# Wait for provider config to be ready
echo "Waiting for ProviderConfig to be ready..."
kubectl wait providerconfig.backblaze.upbound.io --all --for condition=Ready --timeout=300s

# Test bucket creation
echo "Testing bucket creation..."
BUCKET_NAME="test-crossplane-bucket-$(date +%s)"
cat <<EOF | kubectl apply -f -
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: Bucket
metadata:
  name: test-bucket
  namespace: backblaze-test
spec:
  forProvider:
    bucketName: ${BUCKET_NAME}
    bucketType: allPrivate
    bucketInfo:
      purpose: "Crossplane test bucket"
      environment: "test"
  providerConfigRef:
    name: default
EOF

# Wait for bucket to be ready
echo "Waiting for bucket to be ready..."
kubectl wait bucket.b2.backblaze.upbound.io -n backblaze-test --all --for condition=Ready --timeout=300s

# Test application key creation
echo "Testing application key creation..."
cat <<EOF | kubectl apply -f -
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: ApplicationKey
metadata:
  name: test-app-key
  namespace: backblaze-test
spec:
  forProvider:
    keyName: test-crossplane-key-$(date +%s)
    capabilities:
      - "listBuckets"
      - "listFiles"
      - "readFiles"
    bucketIdSelector:
      matchLabels:
        testing.upbound.io/example-name: test-bucket
  providerConfigRef:
    name: default
EOF

# Wait for application key to be ready
echo "Waiting for application key to be ready..."
kubectl wait applicationkey.b2.backblaze.upbound.io -n backblaze-test --all --for condition=Ready --timeout=300s

# Check resources
echo "Checking created resources..."
kubectl get bucket,applicationkey -n backblaze-test

echo "=== Provider test completed successfully ==="
echo ""
echo "To clean up test resources:"
echo "  kubectl delete namespace backblaze-test"
echo "  kubectl delete providerconfig default"
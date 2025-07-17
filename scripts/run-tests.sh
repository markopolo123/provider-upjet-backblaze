#!/usr/bin/env bash
set -aeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running Backblaze Provider Tests ==="

# Check if uptest is available
if ! command -v uptest &> /dev/null; then
    echo "uptest not found. Installing..."
    # Install uptest
    go install github.com/crossplane/uptest@latest
fi

# Check required environment variables
if [[ -z "${B2_APPLICATION_KEY_ID:-}" || -z "${B2_APPLICATION_KEY:-}" ]]; then
    echo "Error: B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY environment variables must be set"
    echo "Please set these with your Backblaze B2 credentials:"
    echo "  export B2_APPLICATION_KEY_ID=your_key_id"
    echo "  export B2_APPLICATION_KEY=your_key"
    exit 1
fi

# Set up credentials for uptest
export UPTEST_CLOUD_CREDENTIALS="{\"application_key_id\":\"${B2_APPLICATION_KEY_ID}\",\"application_key\":\"${B2_APPLICATION_KEY}\"}"

# Set up test environment
export UPTEST_EXAMPLE_LIST="examples/bucket/bucket.yaml,examples/applicationkey/applicationkey.yaml"
export UPTEST_DATASOURCE_PATH="${PROJECT_ROOT}/cluster/test/datasource.yaml"

# Create datasource file for uptest
cat > "${PROJECT_ROOT}/cluster/test/datasource.yaml" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: uptest-datasource
  namespace: upbound-system
data:
  bucket-name: "upbound-provider-test-bucket-\$(date +%s)"
  key-name: "upbound-provider-test-key-\$(date +%s)"
EOF

# Run tests using make target
echo "Running tests..."
cd "${PROJECT_ROOT}"
make uptest

echo "=== Tests completed ==="
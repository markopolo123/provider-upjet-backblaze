#!/usr/bin/env bash
set -aeuo pipefail

# This script is called before deleting the bucket resource to clean up any files
# that might prevent bucket deletion

echo "Pre-delete hook: Cleaning up bucket contents before deletion"

# Get bucket name from the resource
# If RESOURCE_NAME is not set, use a default name
RESOURCE_NAME=${RESOURCE_NAME:-"example-bucket"}

BUCKET_NAME=$(kubectl get bucket ${RESOURCE_NAME} -o jsonpath='{.spec.forProvider.bucketName}' 2>/dev/null)

if [ -n "${BUCKET_NAME}" ]; then
    echo "Bucket name: ${BUCKET_NAME}"
    echo "Note: In a real scenario, you would use B2 CLI or API to delete all files in the bucket"
    echo "For this test, we assume the bucket is empty or will be cleaned up by B2"
else
    echo "Could not determine bucket name (resource: ${RESOURCE_NAME}), skipping cleanup"
fi

echo "Pre-delete hook completed"
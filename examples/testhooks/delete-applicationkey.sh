#!/usr/bin/env bash
set -aeuo pipefail

# This script is called before deleting the application key resource

echo "Pre-delete hook: Preparing to delete application key"

# Get application key name from the resource
# If RESOURCE_NAME is not set, use a default name
RESOURCE_NAME=${RESOURCE_NAME:-"example-app-key"}

KEY_NAME=$(kubectl get applicationkey ${RESOURCE_NAME} -o jsonpath='{.spec.forProvider.keyName}' 2>/dev/null)

if [ -n "${KEY_NAME}" ]; then
    echo "Application key name: ${KEY_NAME}"
    echo "Application key will be deleted from Backblaze B2"
else
    echo "Could not determine application key name (resource: ${RESOURCE_NAME})"
fi

echo "Pre-delete hook completed"
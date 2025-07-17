#!/usr/bin/env bash
set -aeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running Unit Tests ==="

cd "${PROJECT_ROOT}"

# Run unit tests
echo "Running unit tests..."
go test -v ./config/...
go test -v ./internal/clients/...
go test -v ./config/backblaze/...

# Run tests with coverage
echo "Running tests with coverage..."
go test -coverprofile=coverage.out ./...

# Generate coverage report
echo "Generating coverage report..."
go tool cover -html=coverage.out -o coverage.html

echo "=== Unit tests completed ==="
echo "Coverage report generated: coverage.html"
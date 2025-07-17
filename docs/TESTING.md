# Testing Guide

This guide covers all testing aspects of the Backblaze provider, from unit tests to end-to-end integration tests.

## Test Types

### 1. Unit Tests
Test individual functions and components in isolation.

**Location**: Throughout the codebase with `*_test.go` files

**Run**: 
```bash
./scripts/test-unit.sh
```

**Coverage**:
- Provider configuration validation
- External name configuration
- Client setup functions
- Resource configuration

### 2. Integration Tests (uptest)
Test the provider with real Kubernetes resources and Backblaze API.

**Location**: `examples/` directory with uptest annotations

**Run**:
```bash
./scripts/run-tests.sh
```

**Coverage**:
- Resource creation and deletion
- Provider configuration
- Cross-resource dependencies
- Error handling

### 3. End-to-End Tests
Full provider lifecycle testing in a real Kubernetes cluster.

**Location**: `cluster/test/` directory

**Run**:
```bash
# Bootstrap cluster
./cluster/test/bootstrap-kind.sh

# Build and deploy provider
make local-deploy

# Run tests
./cluster/test/test-provider.sh

# Cleanup
./cluster/test/cleanup.sh
```

## Test Infrastructure

### Kind Cluster Setup
- **Configuration**: `cluster/kind-config.yaml`
- **Bootstrap**: `cluster/test/bootstrap-kind.sh`
- **Features**: 
  - Crossplane pre-installed
  - Proper networking configuration
  - Docker-in-docker support

### Test Credentials
Required environment variables:
```bash
export B2_APPLICATION_KEY_ID="your_key_id"
export B2_APPLICATION_KEY="your_application_key"
```

For uptest:
```bash
export UPTEST_CLOUD_CREDENTIALS='{"application_key_id":"your_key_id","application_key":"your_application_key"}'
```

## Test Scenarios

### Bucket Tests
- **Basic Creation**: Create bucket with minimal configuration
- **Advanced Configuration**: CORS rules, lifecycle policies, encryption
- **Bucket Info**: Custom metadata and tags
- **Deletion**: Clean deletion with proper cleanup

### Application Key Tests
- **Basic Key**: Create key with basic capabilities
- **Restricted Key**: Bucket-specific and prefix-restricted keys
- **Capability Tests**: Various capability combinations
- **Dependency Tests**: Keys depending on buckets

### Integration Tests
- **Cross-resource Dependencies**: Keys referencing buckets
- **Provider Config**: Multiple provider configurations
- **Error Scenarios**: Invalid configurations, API failures
- **Cleanup**: Proper resource cleanup order

## Running Tests

### Prerequisites
```bash
# Install dependencies
go mod download

# Install test tools
go install github.com/crossplane/uptest@latest

# Install Kind (if not already installed)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Quick Test Run
```bash
# Set up credentials
export B2_APPLICATION_KEY_ID="your_key_id"
export B2_APPLICATION_KEY="your_application_key"

# Run all tests
make test
```

### Manual Testing
```bash
# 1. Unit tests
./scripts/test-unit.sh

# 2. Set up test cluster
./cluster/test/bootstrap-kind.sh

# 3. Deploy provider
make local-deploy

# 4. Run integration tests
./cluster/test/test-provider.sh

# 5. Cleanup
./cluster/test/cleanup.sh
```

### CI/CD Testing
Tests are automatically run on:
- Pull requests
- Main branch pushes
- Release creation

## Test Configuration

### Uptest Configuration
File: `uptest-config.yaml`
- Test timeout: 20 minutes
- Resource ready timeout: 10 minutes
- Default conditions: Ready, Synced

### Test Hooks
Pre-deletion hooks ensure proper resource cleanup:
- `examples/testhooks/delete-bucket.sh`
- `examples/testhooks/delete-applicationkey.sh`

## Troubleshooting

### Common Issues

1. **Test Timeout**:
   - Check B2 API rate limits
   - Verify network connectivity
   - Increase timeout in uptest-config.yaml

2. **Authentication Failures**:
   - Verify B2 credentials are correct
   - Check credential format in secrets
   - Ensure proper RBAC permissions

3. **Resource Creation Failures**:
   - Check provider logs: `kubectl logs -n upbound-system deployment/provider-backblaze`
   - Verify CRDs are installed: `kubectl get crd | grep backblaze`
   - Check resource events: `kubectl describe bucket example-bucket`

4. **Clean-up Issues**:
   - Manually delete resources: `kubectl delete bucket,applicationkey --all`
   - Check finalizers: `kubectl get bucket -o yaml`
   - Force delete if needed: `kubectl patch bucket example-bucket --type merge -p '{"metadata":{"finalizers":null}}'`

### Debug Commands
```bash
# Check provider status
kubectl get provider.pkg provider-backblaze

# Check provider logs
kubectl logs -n upbound-system deployment/provider-backblaze

# Check resource status
kubectl get bucket,applicationkey -A -o wide

# Describe resources
kubectl describe bucket example-bucket
kubectl describe applicationkey example-app-key

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Test Data Management

### Test Resource Naming
- Use prefixes: `upbound-provider-test-*`
- Include timestamps: `test-bucket-$(date +%s)`
- Avoid conflicts with existing resources

### Cleanup Strategy
1. Delete dependent resources first (application keys)
2. Delete main resources (buckets)
3. Verify all resources are gone
4. Clean up any orphaned B2 resources

### Test Isolation
- Use separate B2 account for testing
- Limit test account permissions
- Use unique resource names per test run
- Clean up after each test

## Performance Testing

### Load Testing
```bash
# Create multiple resources simultaneously
kubectl apply -f examples/load-test/

# Monitor resource creation
watch kubectl get bucket,applicationkey
```

### Stress Testing
```bash
# Run tests continuously
for i in {1..100}; do
  ./scripts/run-tests.sh
  sleep 30
done
```

## Test Reporting

### Coverage Reports
- Generated by `./scripts/test-unit.sh`
- Available as `coverage.html`
- Target: >80% coverage

### Test Results
- Console output for immediate feedback
- JUnit XML for CI integration
- Coverage reports for code quality

### Metrics
- Test execution time
- Resource creation time
- API call success rate
- Error rates by type
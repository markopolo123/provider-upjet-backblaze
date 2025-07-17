# Testing Infrastructure

This directory contains scripts and configurations for testing the Backblaze provider using Kind.

## Prerequisites

- [Kind](https://kind.sigs.k8s.io/) - Kubernetes in Docker
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [Helm](https://helm.sh/) - Kubernetes package manager
- [Docker](https://www.docker.com/) - Container runtime
- Backblaze B2 account with application key credentials

## Quick Start

1. **Bootstrap Kind cluster with Crossplane**:
   ```bash
   ./bootstrap-kind.sh
   ```

2. **Build and deploy the provider**:
   ```bash
   cd ../..
   make local-deploy
   ```

3. **Set up Backblaze credentials**:
   ```bash
   export B2_APPLICATION_KEY_ID="your_key_id"
   export B2_APPLICATION_KEY="your_application_key"
   ```

4. **Test the provider**:
   ```bash
   ./test-provider.sh
   ```

5. **Clean up**:
   ```bash
   ./cleanup.sh
   ```

## Scripts

### `bootstrap-kind.sh`
- Creates a Kind cluster with Crossplane installed
- Sets up necessary namespaces
- Configures cluster for provider testing

### `test-provider.sh`
- Validates provider functionality
- Creates test resources (bucket, application key)
- Verifies resource creation and readiness

### `cleanup.sh`
- Removes the Kind cluster
- Cleans up kubectl contexts

### `setup.sh`
- Used by uptest framework for automated testing
- Sets up credentials and provider configuration

## Configuration Files

### `kind-config.yaml`
Kind cluster configuration with:
- Single control plane node
- Port mappings for ingress
- Docker socket mount for development

## Testing Workflow

1. **Manual Testing**:
   - Use the scripts above for manual validation
   - Ideal for development and debugging

2. **Automated Testing**:
   - Use `make e2e` for automated testing with uptest
   - Requires `UPTEST_CLOUD_CREDENTIALS` environment variable

3. **CI/CD Testing**:
   - GitHub Actions will use these scripts for automated testing
   - Runs on every pull request and release

## Troubleshooting

### Common Issues

1. **Kind cluster creation fails**:
   - Check Docker is running
   - Ensure no port conflicts on 6443, 80, 443

2. **Provider deployment fails**:
   - Check provider image is built: `make build`
   - Verify Crossplane is running: `kubectl get pods -n crossplane-system`

3. **Resource creation fails**:
   - Check credentials are correct
   - Verify provider config: `kubectl get providerconfig`
   - Check provider logs: `kubectl logs -n upbound-system deployment/provider-backblaze`

### Debug Commands

```bash
# Check provider status
kubectl get provider.pkg

# Check provider logs
kubectl logs -n upbound-system deployment/provider-backblaze

# Check provider config
kubectl get providerconfig -o yaml

# Check CRDs
kubectl get crd | grep backblaze

# Check resources
kubectl get bucket,applicationkey -A
```

## Environment Variables

### Required for Testing
- `B2_APPLICATION_KEY_ID`: Your Backblaze B2 application key ID
- `B2_APPLICATION_KEY`: Your Backblaze B2 application key

### Optional
- `UPTEST_CLOUD_CREDENTIALS`: JSON credentials for uptest (used by `make e2e`)

## Security Notes

- Never commit real credentials to version control
- Use test accounts with limited permissions
- Clean up test resources after testing
- Use separate credentials for CI/CD environments
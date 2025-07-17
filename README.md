# Crossplane Provider for Backblaze B2

[![CI](https://github.com/markopolo123/provider-backblaze/actions/workflows/ci.yaml/badge.svg)](https://github.com/markopolo123/provider-backblaze/actions/workflows/ci.yaml)
[![Release](https://github.com/markopolo123/provider-backblaze/actions/workflows/release.yaml/badge.svg)](https://github.com/markopolo123/provider-backblaze/actions/workflows/release.yaml)
[![Go Report Card](https://goreportcard.com/badge/github.com/markopolo123/provider-backblaze)](https://goreportcard.com/report/github.com/markopolo123/provider-backblaze)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

`provider-backblaze` is a [Crossplane](https://crossplane.io/) provider that enables you to manage [Backblaze B2 Cloud Storage](https://www.backblaze.com/b2/cloud-storage.html) resources directly from Kubernetes. Built using [Upjet](https://github.com/crossplane/upjet), it provides XRM-conformant managed resources for the Backblaze B2 API.

## Features

- **Bucket Management**: Create and manage B2 buckets with lifecycle rules, CORS, and encryption
- **Application Keys**: Manage B2 application keys with scoped permissions and capability restrictions
- **File Management**: Upload and manage files with versioning support
- **Notification Rules**: Configure event notifications for bucket activities
- **Full Kubernetes Integration**: Native Kubernetes CRDs with status conditions and events
- **Crossplane Composition**: Support for Crossplane compositions and composite resources

## Supported Resources

| Resource | Kind | Description |
|----------|------|-------------|
| `b2_bucket` | `Bucket` | B2 storage buckets with lifecycle, CORS, and encryption |
| `b2_application_key` | `ApplicationKey` | B2 API keys with capability restrictions |
| `b2_bucket_file_version` | `BucketFileVersion` | File uploads and version management |
| `b2_bucket_notification_rules` | `BucketNotificationRules` | Event notification configuration |

## Quick Start

### Prerequisites

- Kubernetes cluster with Crossplane installed
- Backblaze B2 account with application key credentials

### Installation

Install the provider using the Crossplane CLI:

```bash
kubectl crossplane install provider ghcr.io/markopolo123/provider-backblaze:latest
```

Or use declarative installation:

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-backblaze
spec:
  package: ghcr.io/markopolo123/provider-backblaze:latest
```

### Configuration

1. Create a secret with your B2 credentials:

```bash
kubectl create secret generic b2-creds \
  --from-literal=credentials='{"application_key_id":"your_id","application_key":"your_key"}'
```

2. Create a ProviderConfig:

```yaml
apiVersion: backblaze.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: b2-creds
      key: credentials
```

### Usage Examples

#### Create a B2 Bucket

```yaml
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: Bucket
metadata:
  name: my-bucket
spec:
  forProvider:
    bucketName: my-crossplane-bucket
    bucketType: allPrivate
    bucketInfo:
      purpose: "Data storage"
      environment: "production"
    lifecycleRules:
    - fileNamePrefix: "temp/"
      daysFromUploadingToHiding: 1
      daysFromHidingToDeleting: 7
    corsRules:
    - corsRuleName: "allow-web"
      allowedOrigins: ["https://example.com"]
      allowedOperations: ["s3_get", "s3_head"]
      allowedHeaders: ["*"]
      maxAgeSeconds: 3600
  providerConfigRef:
    name: default
```

#### Create an Application Key

```yaml
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: ApplicationKey
metadata:
  name: my-app-key
spec:
  forProvider:
    keyName: my-crossplane-key
    capabilities:
      - "listBuckets"
      - "listFiles"
      - "readFiles"
      - "writeFiles"
    bucketIdRef:
      name: my-bucket
  providerConfigRef:
    name: default
```

## Documentation

- [Getting Started Guide](docs/quickstart.md)
- [API Reference](https://doc.crds.dev/github.com/markopolo123/provider-backblaze)
- [Examples](examples/)
- [Testing Guide](docs/TESTING.md)
- [Contributing Guide](CONTRIBUTING.md)

## Development

### Prerequisites

- Go 1.21+
- Docker
- Kind (for local testing)
- kubectl

### Building

```bash
# Clone the repository
git clone https://github.com/markopolo123/provider-backblaze.git
cd provider-backblaze

# Build the provider
make build

# Run code generation
make generate

# Run tests
make test
```

### Testing

```bash
# Run unit tests
./scripts/test-unit.sh

# Set up local test cluster
./cluster/test/bootstrap-kind.sh

# Deploy provider locally
make local-deploy

# Run integration tests
export B2_APPLICATION_KEY_ID="your_key_id"
export B2_APPLICATION_KEY="your_key"
./cluster/test/test-provider.sh

# Clean up
./cluster/test/cleanup.sh
```

### Running Locally

```bash
# Run against a Kubernetes cluster
make run

# Build and push to registry
make all
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Reporting Issues

For bugs, feature requests, or questions, please open an [issue](https://github.com/markopolo123/provider-backblaze/issues) using the appropriate template.

### Security

If you discover a security vulnerability, please refer to our [Security Policy](SECURITY.md).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- 📚 [Documentation](https://github.com/markopolo123/provider-backblaze/tree/main/docs)
- 💬 [GitHub Discussions](https://github.com/markopolo123/provider-backblaze/discussions)
- 🐛 [Issue Tracker](https://github.com/markopolo123/provider-backblaze/issues)
- 🌐 [Crossplane Community](https://crossplane.io/community/)

## Acknowledgments

- [Crossplane](https://crossplane.io/) for the amazing infrastructure orchestration platform
- [Upjet](https://github.com/crossplane/upjet) for the code generation framework
- [Backblaze](https://www.backblaze.com/) for the B2 Cloud Storage service
- The open-source community for their contributions and feedback

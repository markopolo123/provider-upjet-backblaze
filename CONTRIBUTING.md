# Contributing to Crossplane Provider for Backblaze B2

Thank you for your interest in contributing to the Crossplane Provider for Backblaze B2! This document provides guidelines and information for contributors.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

Before submitting a bug report:

1. Check if the issue already exists in our [issue tracker](https://github.com/markopolo123/provider-backblaze/issues)
2. Update to the latest version and see if the issue persists
3. Check the [troubleshooting guide](docs/TESTING.md#troubleshooting)

When filing a bug report, please include:

- Provider version
- Kubernetes version
- Crossplane version
- Resource manifests that reproduce the issue
- Provider logs
- Expected vs actual behavior

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) for consistency.

### Suggesting Features

We welcome feature requests! Please:

1. Check if the feature already exists or is planned
2. Describe the use case and motivation
3. Provide examples of the desired API
4. Reference relevant Backblaze B2 API documentation

Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

### Contributing Code

#### Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/provider-backblaze.git
   cd provider-backblaze
   ```

3. Set up development environment:
   ```bash
   # Install dependencies
   go mod download
   
   # Set up git hooks (optional)
   cp scripts/hooks/pre-commit .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

#### Development Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes:
   ```bash
   # Code your changes
   
   # Run code generation if needed
   make generate
   
   # Run tests
   make test
   
   # Run linting
   make lint
   ```

3. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

4. Push and create a pull request:
   ```bash
   git push origin feature/your-feature-name
   ```

#### Code Style

- Follow standard Go conventions
- Use `gofmt` for formatting
- Run `golangci-lint` for linting
- Write meaningful commit messages following [Conventional Commits](https://www.conventionalcommits.org/)

#### Testing

All contributions must include appropriate tests:

1. **Unit Tests**: Test individual functions and components
   ```bash
   go test ./...
   ```

2. **Integration Tests**: Test with real Backblaze B2 API
   ```bash
   export B2_APPLICATION_KEY_ID="your_key_id"
   export B2_APPLICATION_KEY="your_key"
   ./scripts/run-tests.sh
   ```

3. **End-to-End Tests**: Test full provider lifecycle
   ```bash
   ./cluster/test/bootstrap-kind.sh
   make local-deploy
   ./cluster/test/test-provider.sh
   ```

#### Documentation

- Update relevant documentation in the `docs/` directory
- Include examples in the `examples/` directory
- Update the README if needed
- Add inline code comments for complex logic

#### Pull Request Process

1. Ensure all tests pass
2. Update documentation
3. Fill out the PR template completely
4. Request review from maintainers
5. Address review feedback
6. Ensure CI checks pass

### Resource Configuration

When adding new resources:

1. **Update Provider Configuration**:
   ```go
   // config/backblaze/config.go
   p.AddResourceConfigurator("b2_new_resource", func(r *ujconfig.Resource) {
       r.Kind = "NewResource"
       r.ShortGroup = "b2"
       r.Version = "v1alpha1"
   })
   ```

2. **Add External Name Configuration**:
   ```go
   // config/external_name.go
   var ExternalNameConfigs = map[string]config.ExternalName{
       "b2_new_resource": config.NameAsIdentifier,
   }
   ```

3. **Update Provider Metadata**:
   ```yaml
   # config/provider-metadata.yaml
   b2_new_resource:
     description: "Manages B2 new resource"
     name: b2_new_resource
     title: b2_new_resource Resource
   ```

4. **Add Examples**:
   ```yaml
   # examples/newresource/newresource.yaml
   apiVersion: b2.backblaze.upbound.io/v1alpha1
   kind: NewResource
   metadata:
     name: example-new-resource
   spec:
     forProvider:
       # Resource configuration
   ```

5. **Add Tests**:
   ```go
   // Test the new resource configuration
   func TestNewResourceConfiguration(t *testing.T) {
       // Test implementation
   }
   ```

6. **Update Documentation**:
   - Add resource to README.md
   - Create usage examples
   - Update API documentation

### Release Process

Releases are automated through GitHub Actions:

1. **Version Bump**: Update version in relevant files
2. **Changelog**: Update CHANGELOG.md with new features and fixes
3. **Tag**: Create a git tag following semantic versioning
4. **Release**: GitHub Actions will build and publish the release

### Development Environment

#### Required Tools

- Go 1.21+
- Docker
- kubectl
- Kind (for local testing)
- Helm (for Crossplane installation)

#### Recommended Tools

- [golangci-lint](https://golangci-lint.run/) - Go linter
- [pre-commit](https://pre-commit.com/) - Git hooks
- [uptest](https://github.com/crossplane/uptest) - Testing framework
- [kubectl-crossplane](https://github.com/crossplane/kubectl-crossplane) - Crossplane CLI

#### IDE Configuration

For VS Code, recommended extensions:

- Go extension
- Kubernetes extension
- YAML extension
- GitLens

Sample `.vscode/settings.json`:

```json
{
  "go.testFlags": ["-v"],
  "go.buildFlags": [],
  "go.lintFlags": ["--fast"],
  "go.vetFlags": [],
  "files.eol": "\n",
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.trimTrailingWhitespace": true
}
```

### Architecture

The provider follows the standard Crossplane provider architecture:

```
├── apis/                    # Generated Kubernetes API types
│   ├── b2/v1alpha1/        # B2 resource types
│   └── v1beta1/            # Provider config types
├── config/                 # Provider configuration
│   ├── backblaze/         # Resource configurations
│   └── external_name.go   # External name configurations
├── internal/
│   ├── clients/           # Terraform client setup
│   └── controller/        # Generated controllers
├── examples/              # Resource examples
├── cluster/               # Testing infrastructure
└── docs/                  # Documentation
```

### Common Tasks

#### Adding a New Resource

1. Update Terraform provider version if needed
2. Add resource configuration in `config/backblaze/config.go`
3. Add external name configuration
4. Run code generation: `make generate`
5. Add examples and tests
6. Update documentation

#### Updating Dependencies

1. Update go.mod: `go get -u ./...`
2. Update Terraform provider version in Makefile
3. Regenerate schema: `make generate.init`
4. Run tests to ensure compatibility
5. Update CI if needed

#### Debugging Issues

1. Check provider logs:
   ```bash
   kubectl logs -n crossplane-system deployment/provider-backblaze
   ```

2. Enable debug logging:
   ```bash
   kubectl patch deployment provider-backblaze -n crossplane-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"package-runtime","args":["--debug"]}]}}}}'
   ```

3. Use local development mode:
   ```bash
   make run
   ```

### Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Pull Requests**: Code contributions and reviews

### Recognition

Contributors are recognized in:

- Release notes
- README.md acknowledgments
- GitHub contributor statistics

### Getting Help

If you need help:

1. Check existing documentation
2. Search GitHub issues
3. Ask in GitHub Discussions
4. Join the Crossplane community Slack

Thank you for contributing to the Crossplane Provider for Backblaze B2! Your contributions help make infrastructure management better for everyone. 🚀
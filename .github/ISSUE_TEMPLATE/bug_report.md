---
name: Bug Report
about: Create a report to help us improve the provider
title: ''
labels: 'bug'
assignees: ''

---

## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
Steps to reproduce the behavior:
1. Apply the following manifest: '...'
2. Run command '...'
3. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
A clear and concise description of what actually happened.

## Environment
- Provider version: [e.g. v0.1.0]
- Kubernetes version: [e.g. v1.29.0]
- Crossplane version: [e.g. v1.16.0]
- OS: [e.g. Ubuntu 22.04]

## Resource Manifests
```yaml
# Include the resource manifests that cause the issue
```

## Provider Logs
```
# Include relevant provider logs
kubectl logs -n upbound-system deployment/provider-backblaze
```

## Additional Context
Add any other context about the problem here.

## Possible Solution
If you have ideas about how to fix the issue, please describe them here.
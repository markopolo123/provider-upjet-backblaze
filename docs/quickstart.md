# Quickstart Guide

This guide will help you get started with the Crossplane Provider for Backblaze B2 in just a few minutes.

## Prerequisites

Before you begin, ensure you have:

1. **Kubernetes cluster** (version 1.19+)
2. **Crossplane installed** (version 1.14+)
3. **Backblaze B2 account** with application key credentials
4. **kubectl** configured to access your cluster

## Step 1: Install Crossplane (if not already installed)

If you don't have Crossplane installed, you can install it using Helm:

```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace
```

Wait for Crossplane to be ready:

```bash
kubectl wait --for=condition=Available deployment --all -n crossplane-system --timeout=300s
```

## Step 2: Install the Backblaze Provider

Install the provider using kubectl:

```bash
kubectl apply -f - <<EOF
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-backblaze
spec:
  package: ghcr.io/markopolo123/provider-backblaze:latest
EOF
```

Verify the provider is installed and healthy:

```bash
kubectl get provider provider-backblaze
kubectl wait provider provider-backblaze --for condition=Healthy --timeout=300s
```

## Step 3: Configure Backblaze B2 Credentials

### Get Your B2 Credentials

1. Log in to your [Backblaze B2 account](https://secure.backblaze.com/user_signin.htm)
2. Navigate to **App Keys** in the left sidebar
3. Click **Add a New Application Key**
4. Choose your key type:
   - **Master Application Key**: Full access to your account
   - **Restricted Key**: Limited access (recommended for production)
5. Save the **Application Key ID** and **Application Key**

### Create a Kubernetes Secret

Create a secret containing your B2 credentials:

```bash
kubectl create secret generic b2-creds \
  --from-literal=credentials='{"application_key_id":"YOUR_KEY_ID","application_key":"YOUR_APPLICATION_KEY"}' \
  --namespace crossplane-system
```

**Important**: Replace `YOUR_KEY_ID` and `YOUR_APPLICATION_KEY` with your actual credentials.

## Step 4: Create a ProviderConfig

Create a ProviderConfig that tells the provider how to authenticate with Backblaze B2:

```bash
kubectl apply -f - <<EOF
apiVersion: backblaze.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: b2-creds
      namespace: crossplane-system
      key: credentials
EOF
```

Verify the ProviderConfig is ready:

```bash
kubectl get providerconfig default
kubectl wait providerconfig default --for condition=Ready --timeout=60s
```

## Step 5: Create Your First B2 Bucket

Now you're ready to create your first B2 bucket using Crossplane:

```bash
kubectl apply -f - <<EOF
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: Bucket
metadata:
  name: my-first-bucket
spec:
  forProvider:
    bucketName: my-crossplane-bucket-$(date +%s)
    bucketType: allPrivate
    bucketInfo:
      purpose: "My first Crossplane managed bucket"
      environment: "development"
  providerConfigRef:
    name: default
EOF
```

**Note**: Bucket names must be globally unique across all B2 accounts. The `$(date +%s)` adds a timestamp to ensure uniqueness.

## Step 6: Verify Your Bucket

Check that your bucket was created successfully:

```bash
# Check the bucket resource
kubectl get bucket my-first-bucket

# Check the bucket status
kubectl describe bucket my-first-bucket

# Wait for the bucket to be ready
kubectl wait bucket my-first-bucket --for condition=Ready --timeout=300s
```

You should see output similar to:

```
NAME              READY   SYNCED   EXTERNAL-NAME                        AGE
my-first-bucket   True    True     my-crossplane-bucket-1234567890      2m
```

## Step 7: Create an Application Key

Create an application key for your bucket:

```bash
kubectl apply -f - <<EOF
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: ApplicationKey
metadata:
  name: my-bucket-key
spec:
  forProvider:
    keyName: my-crossplane-key-$(date +%s)
    capabilities:
      - "listBuckets"
      - "listFiles"
      - "readFiles"
      - "writeFiles"
    bucketIdRef:
      name: my-first-bucket
  providerConfigRef:
    name: default
EOF
```

Verify the application key:

```bash
kubectl get applicationkey my-bucket-key
kubectl wait applicationkey my-bucket-key --for condition=Ready --timeout=300s
```

## Step 8: View Your Resources

You can view all your Backblaze resources:

```bash
# List all buckets
kubectl get bucket

# List all application keys
kubectl get applicationkey

# Get detailed information
kubectl describe bucket my-first-bucket
kubectl describe applicationkey my-bucket-key
```

## Step 9: Clean Up

To clean up the resources you created:

```bash
# Delete the application key first (due to dependency)
kubectl delete applicationkey my-bucket-key

# Delete the bucket
kubectl delete bucket my-first-bucket

# Optionally, delete the provider config and secret
kubectl delete providerconfig default
kubectl delete secret b2-creds -n crossplane-system
```

## Next Steps

Congratulations! You've successfully set up the Backblaze provider and created your first B2 resources. Here's what you can do next:

### Learn More

- [API Reference](https://doc.crds.dev/github.com/markopolo123/provider-backblaze) - Complete API documentation
- [Examples](../examples/) - More complex examples and use cases
- [Testing Guide](TESTING.md) - How to test your configurations

### Advanced Features

- **Lifecycle Rules**: Automatically manage file retention
- **CORS Configuration**: Enable cross-origin resource sharing
- **Server-Side Encryption**: Encrypt your data at rest
- **Notification Rules**: Get notified about bucket events
- **Crossplane Compositions**: Create reusable infrastructure patterns

### Example with Advanced Features

```yaml
apiVersion: b2.backblaze.upbound.io/v1alpha1
kind: Bucket
metadata:
  name: advanced-bucket
spec:
  forProvider:
    bucketName: my-advanced-bucket
    bucketType: allPrivate
    bucketInfo:
      purpose: "Advanced example bucket"
      environment: "production"
    lifecycleRules:
    - fileNamePrefix: "logs/"
      daysFromUploadingToHiding: 30
      daysFromHidingToDeleting: 90
    - fileNamePrefix: "temp/"
      daysFromUploadingToHiding: 1
      daysFromHidingToDeleting: 7
    corsRules:
    - corsRuleName: "web-app"
      allowedOrigins: ["https://myapp.com"]
      allowedOperations: ["s3_get", "s3_head"]
      allowedHeaders: ["authorization", "x-requested-with"]
      maxAgeSeconds: 3600
    defaultServerSideEncryption:
    - mode: "SSE-B2"
      algorithm: "AES256"
  providerConfigRef:
    name: default
```

### Troubleshooting

If you encounter issues:

1. **Check provider logs**:
   ```bash
   kubectl logs -n crossplane-system deployment/provider-backblaze
   ```

2. **Verify credentials**:
   ```bash
   kubectl get secret b2-creds -n crossplane-system -o yaml
   ```

3. **Check resource events**:
   ```bash
   kubectl describe bucket my-first-bucket
   ```

4. **Validate ProviderConfig**:
   ```bash
   kubectl get providerconfig default -o yaml
   ```

### Getting Help

- [GitHub Issues](https://github.com/markopolo123/provider-backblaze/issues) - Report bugs or ask questions
- [Crossplane Community](https://crossplane.io/community/) - Join the community
- [Backblaze B2 Documentation](https://www.backblaze.com/b2/docs/) - Learn more about B2

That's it! You're now ready to manage your Backblaze B2 resources using Crossplane. Happy cloud native storage management! 🚀
# Deploying JFrog Xray with Catalog Valkey Caching

This example shows how to deploy JFrog Xray with Catalog using Valkey for caching. Valkey is an open-source, in-memory data structure store that acts as a cache to improve performance.

## Enabling Valkey for Catalog

Valkey is a separate pod that runs alongside your Xray deployment. When you enable catalog caching (`catalog.cache.enabled: true`), the Catalog service will use Valkey to store and retrieve cached data quickly, reducing load times and improving efficiency.

## Configuration

To enable Valkey caching for Catalog, you need to set the following in your `values.yaml` file:

```yaml
catalog:
  enabled: true
  cache:
    enabled: true

xray:
  valkey:
    enabled: true

# RabbitMQ is required for Xray
rabbitmq:
  enabled: true
```

### Changing the Valkey Password

To set a custom password for Valkey, use the global section:

```yaml
global:
  valkey:
    password: "your-custom-password"
```

## Deployment

1. Create a `custom-values.yaml` file with the configurations above (or use the provided `values-xray.yaml`).

2. Run the Helm upgrade command:

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f values-xray.yaml
```

This will deploy Xray with Catalog enabled and Valkey caching active. The Valkey pod will start automatically, and Catalog will connect to it for caching operations.

## Verification

After deployment, verify that Valkey caching is working:

- Check that the Valkey pod is up and running: `kubectl get pods -n jfrog-platform | grep valkey`
- Verify the Catalog pod is running: `kubectl get pods -n jfrog-platform | grep catalog`
- Confirm the Catalog pod system.yaml (/opt/jfrog/catalog/var/etc/system.yaml)  configuration has `cache.enabled: true` and `connectionString` set
- Further more to verify, enable debug logs in Catalog to see cache operations: Look for `Get key:` and `Set key:` log lines to confirm Catalog is using Valkey
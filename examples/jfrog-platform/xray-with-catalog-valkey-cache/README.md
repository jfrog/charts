# Deploying JFrog Xray with Catalog Valkey Caching

This example shows how to deploy JFrog Xray with Catalog using Valkey for caching. Valkey is an open-source, in-memory data structure store that acts as a cache to improve performance.

## What is Valkey?

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
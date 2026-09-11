# Deploying Xray with Catalog Valkey Caching

This example shows how to deploy Xray with Catalog using Valkey for caching. Valkey is an open-source, in-memory data structure store that acts as a cache to improve performance.

> [!NOTE]
> This example targets the standalone **`xray`** chart. If you are deploying the umbrella **`jfrog-platform`** chart instead, the value structure is different (Valkey is nested under `xray.valkey`). See [`examples/jfrog-platform/xray-with-catalog-valkey-cache`](../../jfrog-platform/xray-with-catalog-valkey-cache/README.md) for that variant.

## Enabling Valkey for Catalog

Valkey is a separate pod that runs alongside your Xray deployment. When you enable catalog caching (`catalog.cache.enabled: true`), the Catalog service will use Valkey to store and retrieve cached data quickly, reducing load times and improving efficiency.

## Configuration

To enable Valkey caching for Catalog, you need to set the following in your `values.yaml` file:

```yaml
catalog:
  enabled: true
  cache:
    enabled: true

valkey:
  enabled: true

# RabbitMQ is required for Xray (enabled by default in the xray chart)
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

### Enabling Valkey in Sentinel (High Availability) Mode

The single-node (standalone) configuration above runs a single Valkey pod, which is a single point of failure. For production or high-availability deployments, you can run Valkey in **replication** mode with **Sentinel** enabled. In this mode, Valkey runs one primary and multiple replicas, and Sentinel monitors them and automatically promotes a replica to primary if the current primary fails.

The way Sentinel is enabled depends on your chart version.

#### From 3.150.x onwards (Sentinel enabled by default)

Starting with version `3.150.x`, Sentinel-based high availability is the built-in default for Valkey. You do **not** need to provide any replication or Sentinel configuration — simply enabling Valkey is enough:

```yaml
catalog:
  enabled: true
  cache:
    enabled: true

valkey:
  enabled: true

# RabbitMQ is required for Xray (enabled by default in the xray chart)
rabbitmq:
  enabled: true
```

#### From 3.143.9 up to 3.150.x (manual configuration)

On versions from `3.143.9` up to (but not including) `3.150.x`, Sentinel is supported but must be configured explicitly. Provide the full configuration under the top-level `valkey` key in your `values.yaml`:

```yaml
catalog:
  enabled: true
  cache:
    enabled: true

valkey:
  enabled: true
  architecture: replication
  rbac:
    create: true
  replica:
    replicaCount: 3
    automountServiceAccountToken: true
    persistence:
      enabled: true
      size: 1Gi
  sentinel:
    enabled: true
    image:
      registry: releases-docker.jfrog.io
      repository: bitnami/valkey-sentinel
      tag: 8.1-echo
    downAfterMilliseconds: 2000
    failoverTimeout: 18000
    automateClusterRecovery: true
    service:
      createPrimary: true
  kubectl:
    image:
      registry: releases-docker.jfrog.io
      repository: echohq/kubectl
      tag: 1.35.6

# RabbitMQ is required for Xray (enabled by default in the xray chart)
rabbitmq:
  enabled: true
```

You can still override the password using the `global.valkey.password` setting described above.

> [!CAUTION]
> **When upgrading to `3.150.x`, remove the `valkey.sentinel.image.tag` and `valkey.kubectl.image.tag` overrides from your values.**
> If you previously configured Sentinel manually, your values file pins these image tags. Leaving them pinned prevents you from receiving the image versions shipped with subsequent chart upgrades. Delete both `tag` entries so the chart manages the images and you automatically get future updates.

## Deployment

1. Create a `custom-values.yaml` file with the configurations above (or use the provided `values-xray.yaml`).

2. Run the Helm upgrade command:

```console
helm upgrade --install xray --namespace xray --create-namespace jfrog/xray -f values-xray.yaml
```

This will deploy Xray with Catalog enabled and Valkey caching active. The Valkey pod will start automatically, and Catalog will connect to it for caching operations.

## Verification

After deployment, verify that Valkey caching is working:

- Check that the Valkey pod is up and running: `kubectl get pods -n xray | grep valkey`
- Verify the Catalog pod is running: `kubectl get pods -n xray | grep catalog`
- Confirm the Catalog pod system.yaml (/opt/jfrog/catalog/var/etc/system.yaml)  configuration has `cache.enabled: true` and `connectionString` set
- Further more to verify, enable debug logs in Catalog to see cache operations: Look for `Get key:` and `Set key:` log lines to confirm Catalog is using Valkey

# Fresh Install with RabbitMQ 4.x and Quorum Queues

This example shows how to perform a fresh installation of JFrog Xray with RabbitMQ 4.x and quorum queues enabled from the start. Since this is a fresh install, no migration steps are required.

## Configuration

```yaml
global:
  xray:
    rabbitmq:
      replicaCount: 3
      haQuorum:
        enabled: true
      migrateMessagesFromXrayDefaultVhost: true

rabbitmq:
  image:
    tag: 4.1.5-debian-12-r1
  replicaCount: 3
  podManagementPolicy: Parallel
  extraPlugins: "rabbitmq_shovel rabbitmq_shovel_management"
  migration:
    deleteStatefulSetToAllowFieldUpdate:
      enabled: true
    removeHaPolicyOnMigrationToHaQuorum:
      enabled: true
```

## Deployment

1. Create a `custom-values.yaml` file with the configuration above (or use the provided `values-xray.yaml`).

2. Run the Helm install command:

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f values-xray.yaml
```

## Verification

After deployment, verify that RabbitMQ 4.x is running with quorum queues:

- Check that all three RabbitMQ pods are up and running:

```bash
kubectl get pods -n jfrog-platform | grep rabbitmq
```

- Confirm the RabbitMQ version:

```bash
rabbitmqctl version
```

- Confirm quorum queues are created:

```bash
rabbitmqctl -p xray_haq list_queues name type messages_ready messages_unacknowledged consumers
```

## References

- [Quorum Queue Enablement for Xray and Platform Helm Charts](https://jfrog.com/help/r/jfrog-installation-setup-documentation/quorum-queue-enablement-for-xray-and-platform-helm-charts)

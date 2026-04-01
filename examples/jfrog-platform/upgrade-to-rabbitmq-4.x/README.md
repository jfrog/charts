# Upgrade to RabbitMQ 4.x

This example shows how to upgrade JFrog Xray's RabbitMQ to version 4.x.

> **Important:** Switching to RabbitMQ 4.x requires quorum queues to be enabled in the existing deployment. First, switch to quorum queues, and then upgrade to RabbitMQ 4 in a two-stage process.

## Prerequisites

Before proceeding with the RabbitMQ 4.x upgrade, you **must** complete the migration from classic to quorum queues. Refer to the [migrate-from-classic-to-quorum-queues-for-xray](../migrate-from-classic-to-quorum-queues-for-xray) example for the full migration steps.

### Confirm Quorum Migration is Complete

Verify the following log lines in `xray-server-service.log` before proceeding:

1. Confirm message migration is complete:

```
RabbitMQ migration migrate_msgs_from_other_rabbitmq completed successfully
```

2. Confirm classic queues vhost deletion is complete:

```
RabbitMQ migration delete_classic_queues_vhost completed successfully
```

> **Do not proceed with the RabbitMQ 4.x upgrade until both log lines are confirmed.**

## Configuration

Once the quorum queue migration is verified, apply the following configuration to upgrade RabbitMQ to 4.x:

```yaml
rabbitmq:
  image:
    tag: 4.1.5-debian-12-r1
```

## Deployment

1. Create a `custom-values.yaml` file with the configuration above (or use the provided `values-xray.yaml`).

2. Run the Helm upgrade command:

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f values-xray.yaml
```

## Verification

After deployment, verify that RabbitMQ 4.x is running:

```bash
kubectl get pods -n jfrog-platform | grep rabbitmq
```

Confirm the RabbitMQ version by exec-ing into the RabbitMQ pod:

```bash
rabbitmqctl version
```

## References

- [Quorum Queue Enablement for Xray and Platform Helm Charts](https://jfrog.com/help/r/jfrog-installation-setup-documentation/quorum-queue-enablement-for-xray-and-platform-helm-charts)

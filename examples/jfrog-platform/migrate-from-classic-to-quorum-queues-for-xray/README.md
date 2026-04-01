# Migrate from Classic to Quorum Queues for Xray

This example shows how to migrate JFrog Xray from RabbitMQ classic mirrored queues to quorum queues. Quorum queues use Raft consensus for synchronous replication, providing better data safety and more predictable performance. Classic queue mirroring is deprecated in RabbitMQ 4.x, making this migration recommended for all Xray deployments.

> **Important:** Once you switch to quorum queues, rolling back to classic queues is not supported. A RabbitMQ `replicaCount` of 3 is recommended for proper functioning and high availability.

## Configuration

Apply the following configuration to upgrade from classic queues to quorum queues:

```yaml
global:
  xray:
    rabbitmq:
      replicaCount: 3
      haQuorum:
        enabled: true
      migrateMessagesFromXrayDefaultVhost: true

rabbitmq:
  replicaCount: 3
  podManagementPolicy: Parallel
  extraPlugins: "rabbitmq_shovel rabbitmq_shovel_management"
  migration:
    deleteStatefulSetToAllowFieldUpdate:
      enabled: true
    removeHaPolicyOnMigrationToHaQuorum:
      enabled: true
```

### What These Values Do

- **`haQuorum.enabled`** — Enables quorum queues for Xray.
- **`migrateMessagesFromXrayDefaultVhost`** — Migrates existing messages from the default vhost classic queues to the new quorum queues.
- **`replicaCount: 3`** — Required for quorum queue high availability (Raft consensus needs an odd number of nodes).
- **`podManagementPolicy: Parallel`** — Starts all RabbitMQ pods in parallel for faster cluster formation.
- **`extraPlugins`** — Enables the RabbitMQ Shovel plugin used to move messages from classic to quorum queues during migration.
- **`deleteStatefulSetToAllowFieldUpdate`** — Allows the StatefulSet to be recreated to apply field changes that Kubernetes does not allow in-place.
- **`removeHaPolicyOnMigrationToHaQuorum`** — Removes the classic HA mirror policy once migration to quorum queues is complete.

## Deployment

1. Create a `custom-values.yaml` file with the configurations above (or use the provided `values-xray.yaml`).

2. Run the Helm upgrade command:

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f values-xray.yaml
```

## Verification

### 1. Confirm migration from Classic Queue to Quorum Queue is completed

Exec into the xray-server container and check the console log for migration status:

```bash
cat /opt/jfrog/xray/var/log/console.log | grep migrate_msgs_from_other_rabbitmq
```

A successful migration will show logs similar to:

```
0000-00-00T19:32:33.366Z [jfxr ] [INFO ] [...] [system_maintenance_service:254] [MainServer] Checking rabbitmq shovel from configuration element dataMigrations.migrate_msgs_from_other_rabbitmq
0000-00-00T19:32:36.449Z [jfxr ] [INFO ] [...] [system_maintenance_service:403] [MainServer] Rabbitmq shovel check from configuration element dataMigrations.migrate_msgs_from_other_rabbitmq has completed successfully
0000-00-00T19:32:36.493Z [jfxr ] [INFO ] [...] [te_msgs_from_other_rabbitmq:62] [MainServer] Running data migration migrate_msgs_from_other_rabbitmq
0000-00-00T19:32:38.183Z [jfxr ] [INFO ] [...] [te_msgs_from_other_rabbitmq:82] [MainServer] Finished running data migration migrate_msgs_from_other_rabbitmq
```

### 2. Confirm all messages have been migrated from Classic Queues

Port forward the RabbitMQ container port 15672, log in to the RabbitMQ UI, change vhost to `/`, and navigate to Queue and stream. All Classic Queue messages should be zero.

Alternatively, use the below curl command and verify all message counts are zero:

```bash
curl -s -u "$RABBITMQ_USER:$RABBITMQ_PASS" \
  "http://localhost:15672/api/queues/%2F"
```

### 3. Confirm quorum queues are created after the upgrade

```bash
rabbitmqctl -p xray_haq list_queues name type messages_ready messages_unacknowledged consumers
```

This will list all the quorum queues created by Xray.

## References

- [Quorum Queue Enablement for Xray and Platform Helm Charts](https://jfrog.com/help/r/jfrog-installation-setup-documentation/quorum-queue-enablement-for-xray-and-platform-helm-charts)

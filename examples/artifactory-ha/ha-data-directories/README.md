# Set Shared Data Directories and Cold Storage

An Artifactory HA cluster shares a data directory and a backup directory across every node. The chart derives both from the mounted filestore by default, which suits most deployments — set them explicitly only when the shared storage is mounted somewhere the chart doesn't expect, such as an NFS export attached through a custom volume rather than the chart's own persistence.

See the [ha-data-directories-values.yaml](ha-data-directories-values.yaml) for the configuration example.

## How it works
- `artifactory.haDataDir`/`artifactory.haBackupDir` are disabled by default; each needs both `enabled: true` and a `path` — setting a path without enabling it has no effect.
- The path must be reachable and writable from **every** node in the cluster, on shared storage rather than a node-local volume. A path that isn't genuinely shared splits the cluster: each node writes its own copy, and artifacts appear and disappear depending on which node served the request — this reads as intermittent corruption, not a configuration error.
- When the shared storage isn't the chart's own persistent volume, mount it with a custom volume instead (see [custom-volumes](../custom-volumes)) — the claim needs `ReadWriteMany` since every node mounts it at once.
- `artifactory.coldStorage.enabled: true` makes the chart configure Artifactory for cold storage — moving infrequently accessed binaries to a separate, cheaper tier while keeping them retrievable. The flag only wires up the chart side; the tier itself is defined in your filestore configuration (see [binarystore](../../artifactory/binarystore)).

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f ha-data-directories-values.yaml
```

Verify the directories exist and are genuinely shared:
```shell
kubectl exec <pod-name> --namespace artifactory-ha -c artifactory-ha -- ls -ld /var/opt/jfrog/artifactory-ha/data /var/opt/jfrog/artifactory-ha/backup
kubectl exec <pod-0> --namespace artifactory-ha -c artifactory-ha -- touch /var/opt/jfrog/artifactory-ha/data/shared-check
kubectl exec <pod-1> --namespace artifactory-ha -c artifactory-ha -- ls /var/opt/jfrog/artifactory-ha/data/shared-check
```
The second `ls` failing means the path isn't shared, whatever the mount looks like.

## Related
- [ha-data-directories](../../jfrog-platform/ha-data-directories) — the jfrog-platform umbrella-chart version.
- [ha-shared-volume-claim](../ha-shared-volume-claim) — an existing shared claim for the data volume itself, a related but distinct mechanism.
- [custom-persistent-volume-claim](../custom-persistent-volume-claim) and [custom-volumes](../custom-volumes) — ways to mount the shared storage these paths point into.
- [binarystore](../../artifactory/binarystore) — where the cold-storage tier itself is actually defined.

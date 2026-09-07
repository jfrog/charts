# Set Shared Data Directories and Cold Storage

An Artifactory HA cluster running through `jfrog-platform` shares a data directory and a backup directory across every node. The chart derives both from the mounted filestore by default — set them explicitly only when the shared storage is mounted somewhere the chart doesn't expect, such as an NFS export attached through a custom volume rather than the chart's own persistence.

See the [ha-data-directories-values.yaml](ha-data-directories-values.yaml) for the configuration example.

> **Note:** `artifactory-ha` is not a subchart of `jfrog-platform` (removed as a dependency in `jfrog-platform` 10.0.0). HA under the platform chart runs through the `artifactory` subchart itself, scaled with `replicaCount` and `persistence.type: cluster-file-system` — see [ha-via-platform-chart](../ha-via-platform-chart). These directory settings apply to that same subchart.

## How it works
- The keys are double-nested — `artifactory.artifactory.haDataDir`/`haBackupDir`/`coldStorage` — because the standalone chart's own settings live inside its top-level `artifactory:` block (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- Each of `haDataDir`/`haBackupDir` is disabled by default and needs both `enabled: true` and a `path` — setting a path without enabling it has no effect.
- The path must be reachable and writable from **every** Artifactory replica, on shared storage rather than a node-local volume. A path that isn't genuinely shared splits the cluster: each replica writes its own copy, and artifacts appear and disappear depending on which replica served the request.
- `coldStorage.enabled: true` only wires up the chart side; the storage tier itself is defined in your filestore configuration.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f ha-data-directories-values.yaml
```

## Related
- [ha-data-directories](../../artifactory-ha/ha-data-directories) — the standalone `artifactory-ha` chart version.
- [ha-via-platform-chart](../ha-via-platform-chart) — the HA scaling this example builds on.
- [custom-persistent-volume-claim](../custom-persistent-volume-claim) — a way to mount the shared storage these paths point into.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

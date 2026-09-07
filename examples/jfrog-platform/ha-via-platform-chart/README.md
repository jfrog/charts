# Artifactory High Availability via the Platform Chart

This example shows how to run Artifactory in a multi-node, highly available configuration through the `jfrog-platform` umbrella chart using `artifactory.artifactory.replicaCount` and `artifactory.artifactory.persistence.type`.

> **Important:** `artifactory-ha` is **not** a subchart of `jfrog-platform` — it was removed as a platform dependency in `jfrog-platform` 10.0.0. Setting `artifactory-ha.*` keys in a `jfrog-platform` values file has no effect; the chart has no subchart by that name to apply them to. HA under the platform chart is achieved entirely through the `artifactory` subchart's own `replicaCount` and shared-storage `persistence.type`.

See the [ha-via-platform-chart-values.yaml](ha-via-platform-chart-values.yaml) for the configuration example.

## How it works

- `artifactory.artifactory.replicaCount` scales the Artifactory subchart to multiple pods, all backed by the same PostgreSQL database provisioned by the platform chart.
- `artifactory.artifactory.persistence.type: cluster-file-system` switches Artifactory's filestore from the single-node default (`file-system`) to a mode where every replica shares the same underlying volume — required so all nodes see the same binaries.
- Every Artifactory replica still needs its own valid license slot; see the [multi-node licensing example](../../artifactory-ha/multi-node-license) for how license counts scale with node count (same underlying requirement, different chart).
- Because the umbrella chart always nests a subchart's values under its own name, these two settings are the platform-chart equivalent of the standalone `artifactory` chart's `replicaCount` / `persistence.type` — see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for the general translation rule.

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f ha-via-platform-chart-values.yaml
```

## Notes

- A shared, RWX-capable storage class is required for `cluster-file-system` persistence — a single-writer PVC will not work across multiple Artifactory pods.
- This does not replace the standalone `artifactory-ha` chart, which has its own `artifactory.primary`/`artifactory.node` structure and is still published separately for deployments that don't need the rest of the platform (Xray, Catalog, etc.).

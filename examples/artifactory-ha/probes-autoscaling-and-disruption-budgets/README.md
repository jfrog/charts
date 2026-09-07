# Probes, Autoscaling, and Disruption Budgets

Three settings decide how Kubernetes treats the Artifactory HA cluster over its lifetime: when a pod is considered healthy (`startupProbe`/`livenessProbe`/`readinessProbe`), when it gets more replicas (`autoscaling`), and how many primary-node replicas must stay up during node maintenance (`minAvailable`, via a PodDisruptionBudget).

See the [probes-autoscaling-and-disruption-budgets-values.yaml](probes-autoscaling-and-disruption-budgets-values.yaml) for the configuration example.

## How it works
- `artifactory.startupProbe.config` (and `livenessProbe`/`readinessProbe`) stays flat under `artifactory:` — same key path as the standalone chart, **not** scoped under `artifactory.primary`. It's a complete, `tpl`-rendered YAML block; replace the whole block, not a single field. Raise `startupProbe.failureThreshold` (rather than loosening the liveness probe) to tolerate slow storage without a restart loop.
- `probes.timeoutSeconds` and `autoscaling` are both **chart-root** keys, unchanged from the standalone chart — not nested under `artifactory:` at all.
- `artifactory.primary.resources` must be set for autoscaling's CPU-utilization target to mean anything — `autoscaling.minReplicas`/`maxReplicas`/`targetCPUUtilizationPercentage` correspond to the primary nodes specifically (autoscaling is only supported for the primary StatefulSet).
- `artifactory.primary.updateStrategy.type: RollingUpdate` (the default) and `artifactory.primary.minAvailable` are nested one level deeper than the standalone chart, under `artifactory.primary` — HA distinguishes primary-node settings from other components. `minAvailable` is unset by default (no PodDisruptionBudget object exists until you set it), and setting it equal to (or above) `primary.replicaCount` blocks all voluntary eviction, hanging node drains and cluster upgrades.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f probes-autoscaling-and-disruption-budgets-values.yaml
```

## Related
- [probes-autoscaling-and-disruption-budgets](../../artifactory/probes-autoscaling-and-disruption-budgets) — the standalone-chart version.
- [probes-autoscaling-and-disruption-budgets](../../jfrog-platform/probes-autoscaling-and-disruption-budgets) — the jfrog-platform umbrella-chart version.
- [pod-placement-and-priority](../pod-placement-and-priority) — anti-affinity and topology spread, the scheduling half of availability.
- [ha-resource-sizing](../ha-resource-sizing) — sizing `artifactory.primary.resources` in more depth.

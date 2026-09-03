# Probes, Autoscaling, and Disruption Budgets

Three settings decide how Kubernetes treats the Artifactory pod over its lifetime: when it's considered healthy (`startupProbe`/`livenessProbe`/`readinessProbe`), when it gets more replicas (`autoscaling`), and how many replicas must stay up during node maintenance (`minAvailable`, via a PodDisruptionBudget).

See the [probes-autoscaling-and-disruption-budgets-values.yaml](probes-autoscaling-and-disruption-budgets-values.yaml) for the configuration example.

## How it works
- `artifactory.startupProbe.config` (and `livenessProbe`/`readinessProbe`) is a complete, `tpl`-rendered YAML block — replace the whole block, not a single field. Artifactory can take several minutes to start on slow or heavily loaded storage; when the startup probe gives up first, Kubernetes restarts the container and it never finishes starting, producing a restart loop that looks like a crash. Raise `startupProbe.failureThreshold` rather than loosening the liveness probe, so a genuinely stuck process is still detected once running.
- `probes.timeoutSeconds` is a **chart-root** key (not nested under `artifactory:`) — one timeout applies to every probe.
- `autoscaling` is also chart-root, and disabled by default. It needs `artifactory.resources.requests` set, because the target percentage is measured against the request — with `resources: {}` the HPA has nothing to compute against and never scales. Scaling Artifactory beyond one replica additionally requires an Enterprise license and a shared filestore; raising `maxReplicas` alone isn't enough.
- `artifactory.minAvailable` is unset by default, so no PodDisruptionBudget object is created until you set it. Setting it equal to (or above) `replicaCount` means no pod can ever be evicted voluntarily — node drains hang and cluster upgrades stall on that node.
- `artifactory.updateStrategy.type: RollingUpdate` (the default) replaces pods one at a time and waits for each to become ready; `OnDelete` leaves pods on the old version until you delete them yourself.
- On Artifactory HA, `minAvailable` and `updateStrategy` nest one level deeper under `artifactory.primary` (see [probes-autoscaling-and-disruption-budgets](../../artifactory-ha/probes-autoscaling-and-disruption-budgets)); `autoscaling`/`probes` stay at chart root on both charts.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f probes-autoscaling-and-disruption-budgets-values.yaml
```

## Related
- [probes-autoscaling-and-disruption-budgets](../../artifactory-ha/probes-autoscaling-and-disruption-budgets) — the HA version, with the primary-node nesting differences.
- [probes-autoscaling-and-disruption-budgets](../../jfrog-platform/probes-autoscaling-and-disruption-budgets) — the jfrog-platform umbrella-chart version.
- [pod-placement-and-priority](../pod-placement-and-priority) — anti-affinity and topology spread, the scheduling half of availability.
- [resource-jvm-sizing](../resource-jvm-sizing) — `artifactory.resources` must be set for the CPU-utilization target above to mean anything.

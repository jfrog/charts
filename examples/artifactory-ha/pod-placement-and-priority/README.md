# Control Pod Placement and Priority

Kubernetes decides where each Artifactory HA primary pod runs. This example shows the standard scheduling controls the chart exposes — `nodeSelector`, `tolerations`, `podAntiAffinity`, `topologySpreadConstraints` — plus which pods get evicted first under resource pressure (`priorityClass`).

See the [pod-placement-and-priority-values.yaml](pod-placement-and-priority-values.yaml) for the configuration example.

## How it works
- `artifactory.primary.nodeSelector`, `artifactory.primary.tolerations`, and `artifactory.primary.podAntiAffinity` nest one level deeper than the standalone chart, under `artifactory.primary` — HA distinguishes primary-node scheduling from other components (`nginx`, `frontend`, and so on, which each have their own independent placement keys). Label the node first with `kubectl label node <node-name> jfrog-workload=artifactory` before applying `nodeSelector`.
- `artifactory.priorityClass` and `artifactory.topologySpreadConstraints`, by contrast, stay **flat** under `artifactory:` — not primary-scoped — and apply to the primary pods regardless.
- `podAntiAffinity` is only applied when `affinity` is empty — supplying your own `affinity` block under `artifactory.primary` replaces this generated rule entirely. `type: "hard"` refuses to schedule a replica that would share a node with an existing one; the default `"soft"` still schedules pods even when it can't spread them, so on a capacity-constrained cluster all replicas can silently end up co-located.
- `artifactory.priorityClass.create: true` creates a new PriorityClass (or set `existingPriorityClass: <name>` to reuse one already in the cluster). The Nginx deployment uses a different shape — a plain `nginx.priorityClassName` string field, not the block form.

## Deploy
```shell
kubectl label node <node-name> jfrog-workload=artifactory
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f pod-placement-and-priority-values.yaml
```

## Related
- [pod-placement-and-priority](../../artifactory/pod-placement-and-priority) — the standalone-chart version.
- [pod-placement-and-priority](../../jfrog-platform/pod-placement-and-priority) — the jfrog-platform umbrella-chart version.
- [probes-autoscaling-and-disruption-budgets](../probes-autoscaling-and-disruption-budgets) — the health/scaling/eviction half of availability.

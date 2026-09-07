# Control Pod Placement and Priority

Kubernetes decides where the Artifactory subchart's pod runs when it's deployed through `jfrog-platform`. This example shows the standard scheduling controls — `nodeSelector`, `tolerations`, `podAntiAffinity`, `topologySpreadConstraints` — plus which pods get evicted first under resource pressure (`priorityClass`).

See the [pod-placement-and-priority-values.yaml](pod-placement-and-priority-values.yaml) for the configuration example.

## How it works
- `nodeSelector`, `tolerations`, `podAntiAffinity`, `topologySpreadConstraints`, and `priorityClass` all live inside the standalone chart's own top-level `artifactory:` block, so under `jfrog-platform` they're **double-nested**: `artifactory.artifactory.nodeSelector`, `artifactory.artifactory.tolerations`, and so on (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for the general rule). Nginx's `priorityClassName`, at the standalone chart's true root, only gets the single subchart-name prefix — `artifactory.nginx.priorityClassName`.
- There's also a global form, `global.nodeSelector`, that applies one selector to every product subchart at once — but not every subchart reads it (Catalog, for example, ignores `global.nodeSelector` and needs `catalog.nodeSelector` set explicitly too).
- `podAntiAffinity` is only applied when `affinity` is empty — supplying your own `affinity` block replaces this generated rule entirely. `type: "hard"` refuses to schedule a replica that would share a node with an existing one; the default `"soft"` still schedules pods even when it can't spread them, so all replicas can silently end up co-located.
- `priorityClass.create: true` creates a new PriorityClass (or set `existingPriorityClass: <name>` to reuse one already in the cluster).

## Deploy
```shell
kubectl label node <node-name> jfrog-workload=artifactory
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f pod-placement-and-priority-values.yaml
```

## Related
- [pod-placement-and-priority](../../artifactory/pod-placement-and-priority) — the standalone-chart version.
- [pod-placement-and-priority](../../artifactory-ha/pod-placement-and-priority) — the artifactory-ha version.
- [probes-autoscaling-and-disruption-budgets](../probes-autoscaling-and-disruption-budgets) — the health/scaling/eviction half of availability.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

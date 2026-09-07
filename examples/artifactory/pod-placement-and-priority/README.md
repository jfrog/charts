# Control Pod Placement and Priority

Kubernetes decides where the Artifactory pod runs. This example shows the standard scheduling controls the chart exposes — `nodeSelector`, `tolerations`, `podAntiAffinity`, `topologySpreadConstraints` — plus which pods get evicted first under resource pressure (`priorityClass`).

See the [pod-placement-and-priority-values.yaml](pod-placement-and-priority-values.yaml) for the configuration example.

## How it works
- `artifactory.nodeSelector` matches node labels exactly; label the node first with `kubectl label node <node-name> jfrog-workload=artifactory`. A global equivalent, `global.nodeSelector`, applies one selector to every product subchart at once (not used by this standalone chart, only relevant under `jfrog-platform`).
- `artifactory.tolerations` lets the pod run on a node carrying a matching taint — pair it with `nodeSelector`/`affinity` when the pod must land there, since a toleration only permits scheduling, it doesn't require it.
- `artifactory.podAntiAffinity` is only applied when `affinity` is empty — supplying your own `affinity` block replaces this generated rule entirely, and any anti-affinity terms you need must then be included in your own block. `type: "hard"` refuses to schedule a replica that would share a node with an existing one (what real high availability requires); `"soft"` asks the scheduler to spread pods but still schedules them when it can't, so all replicas can silently end up co-located on a capacity-constrained cluster; any other value disables anti-affinity entirely.
- `artifactory.topologySpreadConstraints` gives finer control across zones/racks than node-level anti-affinity. `whenUnsatisfiable: DoNotSchedule` enforces the spread; `ScheduleAnyway` treats it as a preference.
- `artifactory.priorityClass.create: true` creates a new PriorityClass (or set `existingPriorityClass: <name>` to reuse one already in the cluster). The Nginx deployment uses a different shape — a plain `nginx.priorityClassName` string field, not the block form.
- Sidecar deployments (`router`, `frontend`) have their own independent placement keys (e.g. `router.nodeSelector`) — setting the product-level value above doesn't move a service that runs as its own Deployment.

## Deploy
```shell
kubectl label node <node-name> jfrog-workload=artifactory
helm upgrade --install artifactory jfrog/artifactory -f pod-placement-and-priority-values.yaml
```

## Related
- [pod-placement-and-priority](../../artifactory-ha/pod-placement-and-priority) — the artifactory-ha version, where several of these nest under `artifactory.primary`.
- [pod-placement-and-priority](../../jfrog-platform/pod-placement-and-priority) — the jfrog-platform umbrella-chart version.
- [probes-autoscaling-and-disruption-budgets](../probes-autoscaling-and-disruption-budgets) — the health/scaling/eviction half of availability.

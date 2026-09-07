# Probes, Autoscaling, and Disruption Budgets

Three settings decide how Kubernetes treats the Artifactory subchart's pod over its lifetime: when it's considered healthy (`startupProbe`/`livenessProbe`/`readinessProbe`), when it gets more replicas (`autoscaling`), and how many replicas must stay up during node maintenance (`minAvailable`, via a PodDisruptionBudget), when Artifactory runs as a subchart of `jfrog-platform`.

See the [probes-autoscaling-and-disruption-budgets-values.yaml](probes-autoscaling-and-disruption-budgets-values.yaml) for the configuration example.

## How it works
- `probes` and `autoscaling` sit at the standalone chart's **root**, not inside its own `artifactory:` block — so under `jfrog-platform` they get only the single subchart-name prefix: `artifactory.probes.timeoutSeconds`, `artifactory.autoscaling`.
- `startupProbe`, `updateStrategy`, and `minAvailable`, by contrast, live inside the standalone chart's own top-level `artifactory:` block, so they're **double-nested** under `jfrog-platform`: `artifactory.artifactory.startupProbe`, `artifactory.artifactory.updateStrategy`, `artifactory.artifactory.minAvailable` (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for the general rule). `artifactory.artifactory.resources` needs the same double prefix, and must be set for autoscaling's CPU-utilization target to mean anything.
- `startupProbe.config` is a complete, `tpl`-rendered YAML block — replace the whole block, not a single field. Raise `failureThreshold` (rather than loosening the liveness probe) to tolerate slow storage without a restart loop.
- `minAvailable` is unset by default (no PodDisruptionBudget object exists until you set it); setting it equal to (or above) `replicaCount` blocks all voluntary eviction, hanging node drains and cluster upgrades. `updateStrategy.type: RollingUpdate` (the default) replaces pods one at a time; `OnDelete` leaves pods on the old version until you delete them yourself.
- On the standalone `artifactory-ha` chart, the double-nesting quirk doesn't apply, but `updateStrategy`/`minAvailable` nest one level under `artifactory.primary` instead — see [probes-autoscaling-and-disruption-budgets](../../artifactory-ha/probes-autoscaling-and-disruption-budgets).

## Deploy
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f probes-autoscaling-and-disruption-budgets-values.yaml
```

## Related
- [probes-autoscaling-and-disruption-budgets](../../artifactory/probes-autoscaling-and-disruption-budgets) — the standalone-chart version.
- [probes-autoscaling-and-disruption-budgets](../../artifactory-ha/probes-autoscaling-and-disruption-budgets) — the artifactory-ha version.
- [pod-placement-and-priority](../pod-placement-and-priority) — anti-affinity and topology spread, the scheduling half of availability.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

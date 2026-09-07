# Add Annotations and Labels

This example sets annotations and labels on the Artifactory HA primary pod, its Service, and its ServiceAccount.

See the [annotations-and-labels-values.yaml](annotations-and-labels-values.yaml) for the configuration example.

## How it works
- `artifactory.annotations` sets pod annotations — verified by rendering, this is the **same flat key as the standalone chart**, *not* nested under `artifactory.primary` the way `resources`/`javaOpts` are (see [ha-resource-sizing](../ha-resource-sizing)).
- `artifactory.primary.labels` sets workload/pod labels — this one is the opposite: it **is** primary-node-scoped. `artifactory.labels` (flat, no `primary.`) exists in the chart's `values.yaml` too but has no effect on the rendered StatefulSet — confirmed by rendering both forms. Annotations and labels are nested at different depths on this chart; don't assume they match.
- `artifactory.service.annotations` controls cloud load balancer behavior on the Artifactory Service, same as standalone.
- `serviceAccount.create: true` plus `serviceAccount.annotations` attaches a cloud identity (e.g. `eks.amazonaws.com/role-arn`) — same root-level keys as the standalone chart.
- Avoid overriding chart-managed label keys (`app`, `component`, `release`) — doing so can break the chart's own pod selectors.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f annotations-and-labels-values.yaml
```

## Verify
```shell
kubectl get pod <pod-name> --namespace artifactory-ha -o jsonpath='{.metadata.annotations}{"\n"}{.metadata.labels}'
```

## Related
- [annotations-and-labels](../../artifactory/annotations-and-labels) — the standalone-chart version.
- [annotations-and-labels](../../jfrog-platform/annotations-and-labels) — the jfrog-platform umbrella-chart version.

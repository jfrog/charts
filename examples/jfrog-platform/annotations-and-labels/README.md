# Add Annotations and Labels

This example sets annotations and labels on the Artifactory pod, its Service, and its ServiceAccount when Artifactory is deployed as a subchart of `jfrog-platform`.

See the [annotations-and-labels-values.yaml](annotations-and-labels-values.yaml) for the configuration example.

## How it works
- Both `artifactory.artifactory.annotations` and `artifactory.artifactory.labels` are double-nested — the outer `artifactory` selects the subchart, the inner `artifactory` is the standalone chart's own top-level block these settings live under (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- `artifactory.artifactory.service.annotations` controls cloud load balancer behavior on the Artifactory Service.
- `artifactory.serviceAccount.create`/`annotations` stays single-nested — `serviceAccount` sits at the standalone chart's true root, not inside its own `artifactory:` block, so it only picks up the one subchart-name prefix.
- There is no `global.annotations`/`global.labels` mechanism — annotating a full platform deployment means setting these values per product (`xray.annotations`, `distribution.annotations`, `catalog.podAnnotations`, `worker.commonAnnotations`, and so on — key names are not consistent across products).
- Avoid overriding chart-managed label keys (`app`, `component`, `release`) — doing so can break the chart's own pod selectors.

## Deploy
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f annotations-and-labels-values.yaml
```

## Related
- [annotations-and-labels](../../artifactory/annotations-and-labels) — the standalone-chart version.
- [annotations-and-labels](../../artifactory-ha/annotations-and-labels) — the artifactory-ha version (note: pod labels nest differently there).
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

# Add Annotations and Labels

Annotations and labels are how you attach cost-allocation tags, trigger service mesh sidecar injection, and bind a Kubernetes service account to a cloud identity. This example sets them on the Artifactory pod, its Service, and its ServiceAccount.

See the [annotations-and-labels-values.yaml](annotations-and-labels-values.yaml) for the configuration example.

## How it works
- `artifactory.annotations` sets pod annotations (read by service meshes and metrics scrapers); `artifactory.labels` sets labels on both the workload and its pods. Annotation values must be quoted strings — an unquoted boolean or number is rejected by Kubernetes.
- `artifactory.service.annotations` controls cloud load balancer behavior on the Artifactory Service — this is where most production annotation work happens (e.g. `service.beta.kubernetes.io/aws-load-balancer-type`).
- `artifactory.statefulset.annotations` annotates the StatefulSet object itself, separately from the pod.
- `serviceAccount.create: true` plus `serviceAccount.annotations` is how cloud identity bindings (e.g. `eks.amazonaws.com/role-arn` for IAM roles for service accounts) attach — the chart must create the ServiceAccount for its annotations to take effect.
- Avoid setting keys the chart already manages on labels, such as `app`, `component`, and `release` — overriding them can break the selectors the chart uses to find its own pods.
- There is no `global.annotations`/`global.labels` mechanism on this chart — annotating a full platform deployment means setting these values on each product individually.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f annotations-and-labels-values.yaml
```

## Verify
```shell
kubectl get pod <pod-name> -o jsonpath='{.metadata.annotations}{"\n"}{.metadata.labels}'
```

## Related
- [annotations-and-labels](../../artifactory-ha/annotations-and-labels) — the artifactory-ha version (note: pod labels nest differently there).
- [annotations-and-labels](../../jfrog-platform/annotations-and-labels) — the jfrog-platform umbrella-chart version.
- [platform-vs-standalone-nesting](../../jfrog-platform/platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

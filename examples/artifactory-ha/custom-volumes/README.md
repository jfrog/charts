# Mount a Custom Volume into the Artifactory HA Containers

This example shows how to mount an extra volume — here, a custom CA certificate from a ConfigMap — into the Artifactory containers using `artifactory.customVolumes` and `artifactory.customVolumeMounts`.

See the [custom-volumes-values.yaml](custom-volumes-values.yaml) for the configuration example.

## How it works
- `artifactory.customVolumes` and `artifactory.customVolumeMounts` use the same shape and same key path as the standalone `artifactory` chart, despite HA otherwise nesting many Artifactory-node settings under `artifactory.primary.*` (see [resource-and-jvm-sizing](../ha-resource-sizing)). Custom volumes are not primary-node-scoped; they apply at the `artifactory` block level.
- Both values are rendered with Helm's `tpl` function, so each is a YAML **string** (block scalar), not a native YAML list — you can reference template values like `{{ .Release.Name }}` inside them.
- The ConfigMap (or Secret) referenced must exist in the same namespace before the pod starts; create it separately, e.g. `kubectl create configmap custom-trust-store --from-file=custom-ca.pem`.
- Both blocks are appended to the pod's existing `volumes`/`volumeMounts` list — they don't replace anything the chart already mounts.

## Deploy
```shell
kubectl create configmap custom-trust-store --namespace artifactory-ha --from-file=custom-ca.pem
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-volumes-values.yaml
```

## Related
- [custom-volumes](../../artifactory/custom-volumes) — the standalone-chart version of this example.
- [custom-volumes](../../catalog/custom-volumes), [custom-volumes](../../distribution/custom-volumes) — the same feature on other product charts.
- [custom-volumes-multi-product](../../jfrog-platform/custom-volumes-multi-product) — the `jfrog-platform` umbrella-chart version, covering multiple products at once.

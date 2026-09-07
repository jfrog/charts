# HPA with a Memory Target Trigger

This example shows how to add a memory-utilization trigger to Artifactory's Horizontal Pod Autoscaler (HPA), in addition to the default CPU trigger, via `autoscaling.metrics`.

See the [hpa-memory-target-values.yaml](hpa-memory-target-values.yaml) for the configuration example.

## How it works
- `autoscaling.enabled: true` turns on the chart's native HPA (a plain Kubernetes `HorizontalPodAutoscaler`, not the KEDA-based mechanism used by `examples/xray/xray-with-keda-hpa` — Artifactory doesn't use KEDA).
- `autoscaling.targetCPUUtilizationPercentage` is the built-in CPU metric; `autoscaling.metrics` is a raw YAML block-scalar string appended alongside it, letting you add arbitrary additional metrics such as a memory-utilization target.
- From Artifactory 7.111, HPA on this single-node chart requires `minReplicas >= 2` (effectively running in HA mode) — the `artifactory-ha` chart has no such restriction since it's already multi-node.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f hpa-memory-target-values.yaml
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.

## Related
See [xray-with-keda-hpa](../../xray/xray-with-keda-hpa) for Xray's KEDA-based autoscaling, and [resource-jvm-sizing](../resource-jvm-sizing) for static resource/JVM sizing instead of autoscaling.
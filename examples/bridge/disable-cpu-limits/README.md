# Bridge Disable CPU Limits
This example shows how to disable CPU limits on the JFrog Bridge container using `resources.disableCpuLimits`.

By default, Kubernetes enforces CPU limits using the CFS (Completely Fair Scheduler) quota mechanism, which can throttle a container even when the node has spare CPU capacity available. This is especially noticeable for CPU-bound or bursty workloads. Setting `resources.disableCpuLimits: true` removes the `cpu` key from `resources.limits` when the chart renders the pod spec, while still applying `resources.requests.cpu` (for scheduling) and `resources.limits.memory` (which is still enforced).

See the [disable-cpu-limits-values.yaml](disable-cpu-limits-values.yaml) for the configuration example.

## How it works
- `resources.disableCpuLimits` is read by the chart's shared resource-rendering helper (from the `jfrog-common` library chart).
- When set to `true`, any `cpu` value under `resources.limits` is dropped from the rendered container spec — only `resources.limits.memory` (if set) and `resources.requests` (both `cpu` and `memory`) are kept.
- When set to `false` (the default) or omitted, `resources.limits.cpu` is rendered as usual.

## Deploy
Install Bridge with the following command:
```shell
helm upgrade --install bridge jfrog/bridge -f disable-cpu-limits-values.yaml
```

## Other components
The same `disableCpuLimits` flag is available under the resources block of other Bridge components, and behaves the same way for each of their containers:
- `router.resources.disableCpuLimits`
- `loggersResources.disableCpuLimits` (log sidecar containers)
- `filebeat.resources.disableCpuLimits`
- `observability.resources.disableCpuLimits`

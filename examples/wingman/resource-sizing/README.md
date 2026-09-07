# Resource Sizing

This example shows how to size the Wingman container's CPU and memory using `resources`.

See the [resource-sizing-values.yaml](resource-sizing-values.yaml) for the configuration example.

## How it works

- `resources` sets standard Kubernetes requests/limits on the Wingman container. The chart's own default is `requests: {cpu: 500m, memory: 1Gi}` / `limits: {memory: 3Gi}` (no CPU limit by default).
- The router, observability, and init containers each have their own independent `resources` blocks (`router.resources`, `observability.resources`, `initContainers.resources`) — sizing the main Wingman container does not affect them.

## Deploy

```shell
helm upgrade --install wingman jfrog/wingman -f resource-sizing-values.yaml
```

See the chart's [values.yaml](../../../stable/wingman/values.yaml) for the full set of configuration options.
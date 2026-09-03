# Enable/Disable In-Pod Platform Services

Artifactory HA runs several JFrog Platform services as containers inside its own pod rather than as separate deployments: `frontend`, `metadata`, `event`, `observability`, `jfconnect`, `jfconfig`, `evidence`, `onemodel` (all `enabled: true` by default), and `platformfederation`, `rtfs` (both `enabled: false` by default, gated by license tier). Each has its own `<service>.enabled` flag. This example demonstrates disabling one default-on service (`observability`, to save resources) and enabling one default-off service (`platformfederation`, an Enterprise+ feature) — the same pattern applies to any of the other eight.

See the [enable-disable-platform-services-values.yaml](enable-disable-platform-services-values.yaml) for the configuration example.

## How it works
- `observability.enabled` and `platformfederation.enabled` are the same chart-root keys, with the same default behavior, as the standalone `artifactory` chart.
- Setting `observability.enabled: false` removes the observability container from the rendered pod spec.
- Setting `platformfederation.enabled: true` turns on an Enterprise+ feature that's off by default; the same per-service `enabled` flag pattern applies to `frontend`, `metadata`, `event`, `jfconnect`, `jfconfig`, `evidence`, `onemodel`, and `rtfs`.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f enable-disable-platform-services-values.yaml
```

## Related
- [enable-disable-platform-services](../../artifactory/enable-disable-platform-services) — the same toggle on standalone Artifactory.
- [enable-disable-platform-services](../../jfrog-platform/enable-disable-platform-services) — the same toggle under the `jfrog-platform` umbrella chart, where these keys nest one level deeper.

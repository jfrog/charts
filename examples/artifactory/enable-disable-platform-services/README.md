# Enable/Disable In-Pod Platform Services

Artifactory runs several JFrog Platform services as containers inside its own pod rather than as separate deployments: `frontend`, `metadata`, `event`, `observability`, `jfconnect`, `jfconfig`, `evidence`, `onemodel` (all `enabled: true` by default), and `platformfederation`, `rtfs` (both `enabled: false` by default, gated by license tier). Each has its own `<service>.enabled` flag. This example demonstrates disabling one default-on service (`observability`, to save resources) and enabling one default-off service (`platformfederation`, an Enterprise+ feature) — the same pattern applies to any of the other eight.

See the [enable-disable-platform-services-values.yaml](enable-disable-platform-services-values.yaml) for the configuration example.

## How it works
- `observability.enabled` and `platformfederation.enabled` are chart-root keys — same tier as `artifactory.customVolumes` or `nginx.tlsSecretName`, not nested under an `artifactory:` block.
- Setting `observability.enabled: false` removes the observability container from the rendered pod spec; it's on by default and safe to disable if you don't use the built-in metrics/tracing endpoints.
- Setting `platformfederation.enabled: true` turns on an Enterprise+ feature that's off by default; the same per-service `enabled` flag pattern applies to `frontend`, `metadata`, `event`, `jfconnect`, `jfconfig`, `evidence`, `onemodel`, and `rtfs`.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f enable-disable-platform-services-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [enable-disable-platform-services](../../artifactory-ha/enable-disable-platform-services) — the same toggle on Artifactory HA.
- [enable-disable-platform-services](../../jfrog-platform/enable-disable-platform-services) — the same toggle under the `jfrog-platform` umbrella chart, where these keys nest one level deeper.
- [enable-apptrust](../enable-apptrust) — the same "in-pod feature toggle" pattern applied to AppTrust specifically.

# Enable Mission Control

This example shows how to enable JFrog Mission Control on a single-node Artifactory instance via `mc.enabled`.

See the [enable-mission-control-values.yaml](enable-mission-control-values.yaml) for the configuration example.

## How it works
- `mc.enabled` is a chart-root key, `false` by default. Mission Control runs inside the Artifactory process rather than as a separate pod.
- `mc.database.maxOpenConnections` and the other `mc.*` tuning values already have working defaults, so no further configuration is required to turn the feature on.
- Mission Control requires an Enterprise+ license; it fails to start on a Pro-tier license.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f enable-mission-control-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also sets `nginx.https.enabled: false` to skip the mandatory TLS-secret gate for this example; use a real `nginx.tlsSecretName` in production.

## Related
See [enable-mission-control](../../artifactory-ha/enable-mission-control) and [enable-mission-control](../../jfrog-platform/enable-mission-control) for the equivalent configuration on the HA and platform charts (same `mc.enabled`/`artifactory.mc.enabled` shape).
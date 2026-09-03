# Enable Mission Control

This example shows how to enable JFrog Mission Control on a multi-node Artifactory HA cluster via `mc.enabled`.

See the [enable-mission-control-values.yaml](enable-mission-control-values.yaml) for the configuration example.

## How it works
- `mc.enabled` is a chart-root key, `false` by default. Mission Control runs inside the Artifactory process rather than as a separate pod.
- `mc.database.maxOpenConnections` and the other `mc.*` tuning values already have working defaults, so no further configuration is required to turn the feature on.
- Mission Control requires an Enterprise+ license; it fails to start on a Pro-tier license.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f enable-mission-control-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
See [enable-mission-control](../../artifactory/enable-mission-control) for the equivalent configuration on the single-node `artifactory` chart, and [enable-mission-control](../../jfrog-platform/enable-mission-control) for the `jfrog-platform` umbrella-chart form.
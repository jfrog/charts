# Enable Artifactory Federation Service (RTFS)

This example shows how to enable the Artifactory Federation Service (RTFS) on a multi-node Artifactory HA cluster via `rtfs.enabled`.

See the [enable-federation-values.yaml](enable-federation-values.yaml) for the configuration example.

## How it works
- Same chart-root `rtfs.enabled` key and shape as the standalone `artifactory` chart. `rtfs.replicaCount` is aligned with `artifactory.primary.replicaCount` at chart defaults, and can be scaled independently.
- The Federation Service microservice must be enabled the same way on every Artifactory node in the cluster — since this is one shared values file applied to the whole HA release, that happens automatically.
- Requires Artifactory 7.104+ and, for a dedicated RTFS database instead of the shared one, 7.146.7+ (see the commented-out `rtfs.database` block in the values file).

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f enable-federation-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [enable-federation](../../artifactory/enable-federation) — the equivalent configuration on the single-node `artifactory` chart.
- [enable-federation](../../jfrog-platform/enable-federation) — the `jfrog-platform` umbrella-chart form.
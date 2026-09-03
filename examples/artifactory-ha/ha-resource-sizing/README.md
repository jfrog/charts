# HA Resource and JVM Sizing

This example shows how to size the primary Artifactory node's container resources and JVM heap in the HA chart using `artifactory.primary.resources` and `artifactory.primary.javaOpts`.

The standalone `artifactory` chart exposes these at the chart root (`resources`, `javaOpts`). The `artifactory-ha` chart nests them under `artifactory.primary` instead, since HA distinguishes primary-node settings from other components (nginx, frontend, and so on).

See the [ha-resource-sizing-values.yaml](ha-resource-sizing-values.yaml) for the configuration example.

## How it works

- `artifactory.primary.javaOpts.xms`/`xmx` set the JVM's initial and maximum heap size for the primary Artifactory container.
- `artifactory.primary.resources` sets standard Kubernetes `requests`/`limits` for the primary Artifactory container.
- Size the JVM heap (`xmx`) below the container memory `limit` to leave headroom for non-heap JVM memory and other process overhead — a common starting point is `xmx` at roughly 60-70% of the memory limit.
- These settings apply only to the primary StatefulSet; other components (`nginx`, `frontend`, `router`) have their own independent `resources` blocks at chart root.

## Deploy

```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f ha-resource-sizing-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```
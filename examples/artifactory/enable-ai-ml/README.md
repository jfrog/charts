# Enable JFrog AI/ML

This example shows how to enable the JFrog AI/ML frontend service on a single-node Artifactory instance via `ml.enabled` and `jfconnect.enabled`.

See the [enable-ai-ml-values.yaml](enable-ai-ml-values.yaml) for the configuration example.

## How it works
- `ml.enabled` is a chart-root key, `false` by default, that flips `frontend.ml.jfrogMlAppState` to `VISIBLE` in the rendered `system.yaml`.
- The chart hard-validates that `jfconnect.enabled` is also `true` whenever `ml.enabled: true` — install fails otherwise. `jfconnect.enabled` already defaults to `true`, but it's shown explicitly here since it's a real requirement, not just a leftover default.
- The chart also fails validation if `ml.enabled: true` is combined with `jfconnect.airgap.enabled: true` — AI/ML requires direct internet connectivity to `https://bridge.ml.jfrog.io` (no proxy support) and cannot run air-gapped.
- Requires an Enterprise+ license (with AI/ML entitlement) and is not supported on Artifactory Edge nodes.
- After enabling, use the Platform UI (**Platform module > AI/ML**) to finish setup, then follow the separate JFrog ML Bridge installation steps — enabling this value only turns on the front-end service.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f enable-ai-ml-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.

## Related
See [enable-ai-ml](../../artifactory-ha/enable-ai-ml) and [enable-ai-ml](../../jfrog-platform/enable-ai-ml) for the equivalent configuration on the HA and platform charts (same `ml.enabled`/`jfconnect.enabled` shape).
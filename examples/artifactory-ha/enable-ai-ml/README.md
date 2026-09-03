# Enable JFrog AI/ML

This example shows how to enable the JFrog AI/ML frontend service on a multi-node Artifactory HA cluster via `ml.enabled` and `jfconnect.enabled`.

See the [enable-ai-ml-values.yaml](enable-ai-ml-values.yaml) for the configuration example.

## How it works
- Same chart-root keys and validation rules as the standalone `artifactory` chart: `ml.enabled` requires `jfconnect.enabled: true`, and fails validation if combined with `jfconnect.airgap.enabled: true`.
- Requires an Enterprise+ license (with AI/ML entitlement) and is not supported on Artifactory Edge nodes.
- Enabling AI/ML flips `frontend.ml.jfrogMlAppState` to `VISIBLE` in the rendered `system.yaml`, applied identically across every HA node.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f enable-ai-ml-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
See [enable-ai-ml](../../artifactory/enable-ai-ml) for the equivalent configuration on the single-node `artifactory` chart, and [enable-ai-ml](../../jfrog-platform/enable-ai-ml) for the `jfrog-platform` umbrella-chart form.
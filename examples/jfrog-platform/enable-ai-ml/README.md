# Enable JFrog AI/ML

This example shows how to enable the JFrog AI/ML frontend service via `artifactory.ml.enabled` and `artifactory.jfconnect.enabled`.

See the [enable-ai-ml-values.yaml](enable-ai-ml-values.yaml) for the configuration example.

## How it works
- `ml` and `jfconnect` are chart-root keys in the standalone `artifactory` chart, so under `jfrog-platform` they need only the single `artifactory.` prefix (unlike `license`, `persistence`, or `replicaCount`, which need the double `artifactory.artifactory.` nesting). Confirmed empirically: setting `artifactory.ml.enabled=true` flips `frontend.ml.jfrogMlAppState` to `VISIBLE` in the rendered `system.yaml`; `artifactory.artifactory.ml.enabled=true` has no effect.
- The chart hard-validates that `artifactory.jfconnect.enabled` is also `true` whenever `artifactory.ml.enabled: true` — install fails otherwise. It also fails if combined with `artifactory.jfconnect.airgap.enabled: true` — AI/ML requires direct internet connectivity to `https://bridge.ml.jfrog.io` and cannot run air-gapped.
- Requires an Enterprise+ license (with AI/ML entitlement) and is not supported on Artifactory Edge nodes.

## Deploy
```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-ai-ml-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
See [enable-ai-ml](../../artifactory/enable-ai-ml) and [enable-ai-ml](../../artifactory-ha/enable-ai-ml) for the equivalent configuration on the standalone `artifactory`/`artifactory-ha` charts (same chart-root `ml.enabled`/`jfconnect.enabled` keys, no extra nesting).
# Unified Secret Installation

By default, Artifactory's internal (chart-managed) secrets are consolidated into a single Kubernetes Secret instead of one Secret object per credential — `unifiedSecretInstallation` controls this, and `unifiedSecretPrependReleaseName` controls whether the release name is prepended to that Secret's name. This only affects secrets the chart itself creates and manages; it has no effect on external secrets you reference by name.

See the [unified-secret-values.yaml](unified-secret-values.yaml) for the configuration example.

## How it works
- `artifactory.unifiedSecretInstallation` defaults to `true` from chart version 107.79.x onward.
- `artifactory.unifiedSecretPrependReleaseName` defaults to `true`.
- Set `unifiedSecretInstallation: false` only to fall back to the older one-Secret-per-credential behavior.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f unified-secret-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [unified-secret](../../artifactory-ha/unified-secret) — the same toggle on Artifactory HA.
- [unified-secret](../../jfrog-platform/unified-secret) — the same toggle under the `jfrog-platform` umbrella chart, where it's pre-set by default and double-nested.
- [custom-secrets](../custom-secrets) — a different secrets mechanism (user-supplied custom secrets, not the chart's own internal credential consolidation).

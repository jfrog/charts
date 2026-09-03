# Unified Secret Installation

By default, Artifactory HA's internal (chart-managed) secrets are consolidated into a single Kubernetes Secret instead of one Secret object per credential — `unifiedSecretInstallation` controls this, and `unifiedSecretPrependReleaseName` controls whether the release name is prepended to that Secret's name. This only affects secrets the chart itself creates and manages; it has no effect on external secrets you reference by name.

See the [unified-secret-values.yaml](unified-secret-values.yaml) for the configuration example.

## How it works
- `artifactory.unifiedSecretInstallation` and `artifactory.unifiedSecretPrependReleaseName` are the same two keys as the standalone chart, defaulting to `true` from chart version 107.78.x onward.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f unified-secret-values.yaml
```

## Related
- [unified-secret](../../artifactory/unified-secret) — the same toggle on standalone Artifactory.
- [unified-secret](../../jfrog-platform/unified-secret) — the same toggle under the `jfrog-platform` umbrella chart, where it's pre-set by default and double-nested.

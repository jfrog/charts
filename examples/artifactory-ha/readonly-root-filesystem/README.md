# Read-Only Root Filesystem

This example shows how to run the Artifactory HA containers with a read-only root filesystem via `containerSecurityContext.readOnlyRootFilesystem`, from Artifactory 7.111.

See the [readonly-root-filesystem-values.yaml](readonly-root-filesystem-values.yaml) for the configuration example.

## How it works
- Same chart-root `containerSecurityContext` key and passthrough mechanism as the standalone `artifactory` chart — not renested under `artifactory.primary.*`.
- With `readOnlyRootFilesystem: true`, only `/var` (the mounted external volume) stays writable; `/app` and everything else becomes read-only.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f readonly-root-filesystem-values.yaml
```

## Related
See [readonly-root-filesystem](../../artifactory/readonly-root-filesystem) for the identical configuration on the single-node `artifactory` chart.
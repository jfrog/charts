# Read-Only Root Filesystem

This example shows how to run the Artifactory container with a read-only root filesystem via `containerSecurityContext.readOnlyRootFilesystem`, from Artifactory 7.111.

See the [readonly-root-filesystem-values.yaml](readonly-root-filesystem-values.yaml) for the configuration example.

## How it works
- `containerSecurityContext` is passed through to the pod's container `securityContext` almost verbatim by the chart (`omit .Values.containerSecurityContext "enabled" | toYaml`) — any key you add here, including `readOnlyRootFilesystem`, takes effect directly with no dedicated chart logic of its own.
- With `readOnlyRootFilesystem: true`, only `/var` (Artifactory's mounted external volume) stays writable; `/app` and everything else becomes read-only, which prevents unauthorized modification of the application files themselves.
- This only affects the Artifactory container's own filesystem — it doesn't change what's mounted or where your data lives.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f readonly-root-filesystem-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also sets `nginx.https.enabled: false` to skip the mandatory TLS-secret gate for this example; use a real `nginx.tlsSecretName` in production.

## Related
See [readonly-root-filesystem](../../artifactory-ha/readonly-root-filesystem) for the identical configuration on the `artifactory-ha` chart.
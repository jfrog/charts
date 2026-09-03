# Enable AppTrust

AppTrust is made up of several interrelated services — Application Trust itself, Unified Policy, Evaluation, and Compliance — that all need to be enabled together.

See the [enable-apptrust-values.yaml](enable-apptrust-values.yaml) for the configuration example.

## How it works

- `apptrust`, `unifiedpolicy`, and `evaluation` are chart-root keys in the standalone `artifactory` chart, so under `jfrog-platform` they need only the single `artifactory.` prefix (unlike `license`, `persistence`, or `replicaCount`, which need the double `artifactory.artifactory.` nesting).
- Compliance has no dedicated `enabled` value of its own — it's turned on by merging `compliance.enabled: true` into Artifactory's `system.yaml` via `artifactory.artifactory.extraSystemYaml`.
- AppTrust requires Artifactory 7.125.x+ and Xray 3.130.5+ with SBOM generation enabled, plus a JFrog Ultimate Security Bundle license. Confirm your license tier and product versions before enabling.

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-apptrust-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
See [enable-apptrust](../../artifactory/enable-apptrust) for the equivalent configuration on the standalone `artifactory` chart (the same keys sit at chart root instead of under `artifactory.*`).
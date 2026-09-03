# Enable AppTrust

AppTrust is made up of several interrelated services — Application Trust itself, Unified Policy, Evaluation, and Compliance — that all need to be enabled together via `apptrust.enabled`, `unifiedpolicy.enabled`, and `evaluation.enabled`.

See the [enable-apptrust-values.yaml](enable-apptrust-values.yaml) for the configuration example.

## How it works
- `apptrust.enabled`, `unifiedpolicy.enabled`, and `evaluation.enabled` are chart-root keys (all `false` by default) — no extra nesting under `artifactory.*`, unlike keys such as `license` or `persistence`.
- Compliance has no dedicated value of its own; it's turned on by merging an entry into `system.yaml` via `artifactory.extraSystemYaml`.
- Requires a recent Artifactory version with SBOM support in Xray and the JFrog Ultimate Security Bundle license — check your license tier and product versions before enabling.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f enable-apptrust-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.

## Related
See [enable-apptrust](../../jfrog-platform/enable-apptrust) for the equivalent configuration when Artifactory is deployed as a subchart of `jfrog-platform` (the same keys nest one level deeper, under `artifactory.*`).
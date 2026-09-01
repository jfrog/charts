# Enable AppTrust

AppTrust is made up of several interrelated services — Application Trust itself, Unified Policy, Evaluation, and Compliance — that all need to be enabled together via `apptrust.enabled`, `unifiedpolicy.enabled`, and `evaluation.enabled`.

See the [enable-apptrust-values.yaml](enable-apptrust-values.yaml) for the configuration example.

## How it works
- `apptrust.enabled`, `unifiedpolicy.enabled`, and `evaluation.enabled` are chart-root keys (all `false` by default) — no extra nesting under `artifactory.*`, unlike keys such as `license` or `persistence`.
- Compliance has no dedicated value of its own; it's turned on by merging an entry into `system.yaml` via `artifactory.extraSystemYaml`.
- Requires a recent Artifactory version with SBOM support in Xray and the JFrog Ultimate Security Bundle license — check your license tier and product versions before enabling.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f enable-apptrust-values.yaml
```

> The values file also includes placeholder `global.masterKey`/`global.joinKey` and `nginx.tlsSecretName` — every fresh Artifactory install requires these regardless of this example's topic. Replace them with your own generated keys and a real TLS secret before deploying to a real cluster.

## Related
See [enable-apptrust](../../jfrog-platform/enable-apptrust) for the equivalent configuration when Artifactory is deployed as a subchart of `jfrog-platform` (the same keys nest one level deeper, under `artifactory.*`).
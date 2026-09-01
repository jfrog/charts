# Unified Secret Installation Across Products

By default, each chart's internal (chart-managed) secrets are consolidated into a single Kubernetes Secret instead of one Secret object per credential — `unifiedSecretInstallation` controls this, and `unifiedSecretPrependReleaseName` controls whether the release name is prepended to that Secret's name. This only affects secrets the chart itself creates and manages; it has no effect on external secrets you reference by name.

<details>
  <summary>Artifactory</summary>

`artifactory.unifiedSecretInstallation` defaults to `true` from chart version 107.79.x onward. `artifactory.unifiedSecretPrependReleaseName` defaults to `true`. Set `unifiedSecretInstallation: false` only to fall back to the older one-Secret-per-credential behavior.

See [unified-secret-artifactory-values.yaml](unified-secret-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f unified-secret-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same two keys, same default-`true` behavior from chart version 107.78.x onward.

See [unified-secret-artifactory-ha-values.yaml](unified-secret-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f unified-secret-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

`jfrog-platform`'s own `values.yaml` already sets `artifactory.artifactory.unifiedSecretInstallation`, `xray.xray.unifiedSecretInstallation`, and `distribution.distribution.unifiedSecretInstallation` to `true` by default — so most installs never need to touch this. The double-nesting (subchart name + the standalone chart's own self-wrapped block) matches the same pattern documented in [extra-system-yaml-across-products](../extra-system-yaml-across-products): Artifactory and Distribution self-wrap, so they double-nest; a hypothetical Xray-`common`-scoped setting would not.

See [unified-secret-jfrog-platform-values.yaml](unified-secret-jfrog-platform-values.yaml) for the explicit override form (useful if you need to flip one product back to per-secret installation without touching the others).

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f unified-secret-jfrog-platform-values.yaml
```
</details>

## References
- [extra-system-yaml-across-products](../extra-system-yaml-across-products) — the same double-nesting pattern, verified empirically there.
- [custom-secrets-across-products](../custom-secrets-across-products) — a different secrets mechanism (user-supplied custom secrets, not the chart's own internal credential consolidation).
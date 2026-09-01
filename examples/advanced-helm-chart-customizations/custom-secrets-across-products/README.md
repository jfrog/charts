# Custom Secrets Across Products

`customSecrets` creates a Kubernetes Secret from data you provide directly in `values.yaml` — one entry per file — for use inside a custom init container or sidecar (see [custom-init-containers-across-products](../custom-init-containers-across-products) and [custom-sidecars-across-products](../custom-sidecars-across-products)). To actually mount it into a container, pair it with a `customVolumes` entry of type `secret` and a volume mount in the consuming container.

<details>
  <summary>Artifactory</summary>

`artifactory.customSecrets` (list of `name`/`key`/`data` entries) nests inside the chart's own `artifactory:` block. Reference the resulting Secret from `artifactory.customVolumes` by name.

See [custom-secrets-artifactory-values.yaml](custom-secrets-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f custom-secrets-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same shape and key path as standalone Artifactory — `artifactory.customSecrets`.

See [custom-secrets-artifactory-ha-values.yaml](custom-secrets-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-secrets-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

Artifactory's `customSecrets` is double-nested under the platform chart (`artifactory.artifactory.customSecrets`), same as `extraSystemYaml` and `unifiedSecretInstallation` — because the standalone Artifactory chart wraps its own settings in a self-named `artifactory:` block. Xray is different: its `customSecrets` lives under a separate `common:` root block in the standalone chart (not inside a self-named `xray:` block), so under the platform chart it's single-nested as `xray.common.customSecrets`. Distribution follows Artifactory's pattern (`distribution.distribution.customSecrets`).

See [custom-secrets-jfrog-platform-values.yaml](custom-secrets-jfrog-platform-values.yaml) for a worked example covering both Artifactory and Xray.

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-secrets-jfrog-platform-values.yaml
```
</details>

## References
- [custom-init-containers-across-products](../custom-init-containers-across-products), [custom-sidecars-across-products](../custom-sidecars-across-products) — where a custom secret's mounted volume typically gets consumed.
- [extra-system-yaml-across-products](../extra-system-yaml-across-products) — the same self-wrapped-block double-nesting quirk, verified there too.
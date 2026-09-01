# Custom Init Containers Across Products

Every product chart lets you inject custom init containers around its own predefined ones, via a `tpl`-rendered YAML-list string — `customInitContainersBegin` runs before the chart's built-in init containers, `customInitContainers` runs after. All examples below use the same product-scoped keys already validated by [custom-volumes-across-products](../custom-volumes-across-products) for baseline patterns.

> **Reserved at the platform level:** `global.customInitContainersBegin` is pre-populated by `jfrog-platform` with `{{ template "initdb" . }}` to bootstrap the bundled PostgreSQL database. Never override it — use the product-scoped key instead (`artifactory.artifactory.customInitContainersBegin`, not `global.customInitContainersBegin`). This is the same warning already given in [custom-volumes-across-products](../custom-volumes-across-products) for `global.customVolumes`.

<details>
  <summary>Artifactory</summary>

`artifactory.customInitContainersBegin` (before) and `artifactory.customInitContainers` (after) — both `tpl`-rendered, so `{{ .Values.* }}` template expressions inside them resolve.

See [custom-init-containers-artifactory-values.yaml](custom-init-containers-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f custom-init-containers-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same two keys, same flat nesting under `artifactory:` as the standalone chart.

See [custom-init-containers-artifactory-ha-values.yaml](custom-init-containers-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-init-containers-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

Double-nested for Artifactory's own keys — `artifactory.artifactory.customInitContainersBegin`/`customInitContainers` — following the same pattern as `license`/`resources`. Other subcharts use their own single-nested `common.*` block instead:

| Product | Path under `jfrog-platform` |
|---|---|
| Artifactory | `artifactory.artifactory.customInitContainersBegin` / `customInitContainers` |
| Xray | `xray.common.customInitContainersBegin` / `customInitContainers` |
| Distribution | `distribution.common.customInitContainersBegin` / `customInitContainers` |

See [custom-init-containers-jfrog-platform-values.yaml](custom-init-containers-jfrog-platform-values.yaml).

```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-init-containers-jfrog-platform-values.yaml
```
</details>

## References
- [custom-volumes-across-products](../custom-volumes-across-products) — the companion topic covering custom volumes/mounts, with the same `global.*` reservation caveat.
- [custom-sidecars-across-products](../custom-sidecars-across-products) — the sidecar-container equivalent of this mechanism.
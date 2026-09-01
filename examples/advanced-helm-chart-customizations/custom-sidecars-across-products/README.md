# Custom Sidecar Containers Across Products

A sidecar is a utility container that runs alongside the main application container in the same pod — for monitoring agents, log collection, or auxiliary services. Every product chart exposes this via `customSidecarContainers`, a `tpl`-rendered YAML-list string, at the same nesting depth as `customVolumes`/`customInitContainers` for that product.

<details>
  <summary>Artifactory</summary>

`artifactory.customSidecarContainers`. Sidecars typically need their own volume/mount, added via `artifactory.customVolumes`/`customVolumeMounts` (see [custom-volumes-across-products](../custom-volumes-across-products)).

See [custom-sidecars-artifactory-values.yaml](custom-sidecars-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f custom-sidecars-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same key and nesting as the standalone chart — `artifactory.customSidecarContainers`.

See [custom-sidecars-artifactory-ha-values.yaml](custom-sidecars-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-sidecars-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

Double-nested for Artifactory — `artifactory.artifactory.customSidecarContainers` — matching `customInitContainers`. Other subcharts use their own `common.customSidecarContainers`:

| Product | Path under `jfrog-platform` |
|---|---|
| Artifactory | `artifactory.artifactory.customSidecarContainers` |
| Xray | `xray.common.customSidecarContainers` |
| Distribution | `distribution.common.customSidecarContainers` |

See [custom-sidecars-jfrog-platform-values.yaml](custom-sidecars-jfrog-platform-values.yaml).

```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-sidecars-jfrog-platform-values.yaml
```
</details>

## References
- [custom-init-containers-across-products](../custom-init-containers-across-products) — the init-container equivalent of this mechanism.
- [custom-volumes-across-products](../custom-volumes-across-products) — sidecars usually need a matching volume/mount from here.
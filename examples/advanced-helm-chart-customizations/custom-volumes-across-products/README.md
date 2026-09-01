# Custom Volumes Across Products

Every product chart lets you mount extra volumes into its containers, but the key path, value type, and mount scope differ per product. This example lays out Artifactory, Artifactory HA, Catalog, Distribution, and JFrog Platform side by side.

<details>
  <summary>Artifactory</summary>

`artifactory.customVolumes`/`artifactory.customVolumeMounts`, rendered with Helm's `tpl` function — each is a YAML **string** (block scalar), not a native list, so you can reference template values like `{{ .Release.Name }}` inside them.

See [custom-volumes-artifactory-values.yaml](custom-volumes-artifactory-values.yaml).

Deploy:
```shell
helm upgrade --install artifactory jfrog/artifactory -f custom-volumes-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same shape and same key path as the standalone chart — `artifactory.customVolumes`/`artifactory.customVolumeMounts` — despite HA otherwise nesting many Artifactory-node settings under `artifactory.primary.*` (see [resource-and-jvm-sizing-across-products](../resource-and-jvm-sizing-across-products)). Custom volumes are not primary-node-scoped; they apply at the `artifactory` block level.

See [custom-volumes-artifactory-ha-values.yaml](custom-volumes-artifactory-ha-values.yaml).

Deploy:
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-volumes-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>Catalog</summary>

`extraVolumes`/`extraVolumeMounts` at chart root — but rendered with `toYaml`, **not** `tpl`. This is the one product here that takes a real native YAML list: don't put `{{ ... }}` template expressions inside it, they won't resolve. There's also a separate `router.extraVolumeMounts` for the Router sidecar.

See [custom-volumes-catalog-values.yaml](custom-volumes-catalog-values.yaml).

Deploy:
```shell
helm upgrade --install catalog jfrog/catalog -f custom-volumes-catalog-values.yaml
```
</details>

<details>
  <summary>Distribution</summary>

`common.customVolumes`/`common.customVolumeMounts`, applied to the main `distribution` container and picked up by the `router` container's mounts too. Like Artifactory, these are `tpl`-rendered strings, not native lists.

See [custom-volumes-distribution-values.yaml](custom-volumes-distribution-values.yaml).

Deploy:
```shell
helm upgrade --install distribution jfrog/distribution -f custom-volumes-distribution-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

Each subchart keeps its own independent mechanism — the umbrella chart never merges or aggregates custom volumes across products, so a mount added for Artifactory has no effect on Xray, Catalog, etc.

| Product | Path under `jfrog-platform` | Value type |
|---|---|---|
| Artifactory | `artifactory.artifactory.customVolumes` / `customVolumeMounts` | `tpl` string |
| Xray | `xray.common.customVolumes` / `customVolumeMounts` | `tpl` string |
| Distribution | `distribution.common.customVolumes` / `customVolumeMounts` | `tpl` string |
| Worker | `worker.common.customVolumes` / `customVolumeMounts` | `tpl` string |
| Catalog | `catalog.extraVolumes` / `extraVolumeMounts` | native YAML list (`toYaml`) |

See [custom-volumes-jfrog-platform-values.yaml](custom-volumes-jfrog-platform-values.yaml) for a worked example mounting into Artifactory, Xray, and Catalog together.

Deploy:
```shell
kubectl create configmap custom-trust-store -n jfrog-platform --from-file=truststore.jks
kubectl create configmap catalog-custom-config -n jfrog-platform --from-file=extra.conf
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-volumes-jfrog-platform-values.yaml
```

> Don't override `global.customVolumes`/`global.customInitContainersBegin` at the platform-chart level — the chart pre-populates these to bootstrap PostgreSQL, and overriding them breaks database initialization. Always use the per-product paths above instead.
</details>

## Related
- [custom-volumes](../../artifactory/custom-volumes), [custom-volumes](../../catalog/custom-volumes), [custom-volumes](../../distribution/custom-volumes) — the narrower, single-chart versions of this example.
- [custom-volumes-multi-product](../../jfrog-platform/custom-volumes-multi-product) — the narrower, jfrog-platform-only version.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.
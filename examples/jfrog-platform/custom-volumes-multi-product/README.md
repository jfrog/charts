# Custom Volumes Across Multiple Products

Each product subchart in `jfrog-platform` exposes its own custom-volume mechanism, and the key path and expected value type differ per product. This example mounts a custom trust store into Artifactory, Xray, and Worker, and a custom config file into Catalog, in a single values file.

See the [custom-volumes-multi-product-values.yaml](custom-volumes-multi-product-values.yaml) for the configuration example.

## How it works

| Product | Values path (under `jfrog-platform`) | Value type |
|---|---|---|
| Artifactory | `artifactory.artifactory.customVolumes` / `customVolumeMounts` | multi-line string (templated with `tpl`) |
| Xray | `xray.common.customVolumes` / `customVolumeMounts` | multi-line string (templated with `tpl`) |
| Distribution | `distribution.common.customVolumes` / `customVolumeMounts` | multi-line string (templated with `tpl`) |
| Worker | `worker.common.customVolumes` / `customVolumeMounts` | multi-line string (templated with `tpl`) |
| Catalog | `catalog.extraVolumes` / `extraVolumeMounts` | **native YAML list** (rendered with `toYaml`, not `tpl`) |

- Artifactory, Xray, Distribution, and Worker all render their custom volumes as a YAML string that's passed through Helm's `tpl` function — this is why the examples below use the `|` block-scalar syntax and can reference template values like `{{ .Release.Name }}` inside the string.
- Catalog is the one product that takes a real YAML list for `extraVolumes`/`extraVolumeMounts`. Writing a `tpl`-style string there does not work — the chart renders it with `toYaml`, so `{{ .Release.Name }}`-style templates inside a string value will **not** resolve.
- The umbrella chart never merges or aggregates these keys across products — each subchart's custom-volume mechanism is independent, so a mount added for Artifactory has no effect on Xray, and vice versa.

## Deploy

```console
kubectl create configmap custom-trust-store -n jfrog-platform --from-file=truststore.jks
kubectl create configmap catalog-custom-config -n jfrog-platform --from-file=extra.conf
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-volumes-multi-product-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Notes

- Don't override `global.customVolumes` / `global.customInitContainersBegin` — the platform chart pre-populates these to bootstrap PostgreSQL, and overriding them at the `global` level (as opposed to the per-product paths above) breaks database initialization.

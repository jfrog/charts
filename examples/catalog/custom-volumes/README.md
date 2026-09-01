# Catalog Custom Volumes

This example shows how to mount an extra volume into the Catalog container using `extraVolumes` and `extraVolumeMounts`.

See the [custom-volumes-values.yaml](custom-volumes-values.yaml) for the configuration example.

## How it works

- `extraVolumes` and `extraVolumeMounts` are rendered with `toYaml`, not `tpl` — unlike some other JFrog charts, these are plain Kubernetes volume/mount specs, not Go-template strings. Don't put `{{ ... }}` expressions inside them; they're copied into the pod spec as-is.
- `extraVolumes` entries go on the pod spec (`spec.volumes`); `extraVolumeMounts` entries go on the main `catalog` container (`spec.containers[].volumeMounts`). They're independent lists, so a volume defined in `extraVolumes` still needs a matching entry in `extraVolumeMounts` to actually be mounted.
- There's a separate `router.extraVolumeMounts` for mounting into the Router sidecar container instead of the main Catalog container.

## Deploy

```shell
helm upgrade --install catalog jfrog/catalog -f custom-volumes-values.yaml
```
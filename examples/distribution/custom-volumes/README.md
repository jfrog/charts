# Custom Volumes

This example shows how to mount a custom volume — for example a private trust store or a config file from a ConfigMap — into every Distribution pod using `common.customVolumes` and `common.customVolumeMounts`.

See the [custom-volumes-values.yaml](custom-volumes-values.yaml) for the configuration example.

## How it works

- `common.customVolumes` and `common.customVolumeMounts` apply to the main `distribution` container (and are also picked up by the `router` container's mounts).
- Both values are YAML block-scalar **strings**, not native YAML lists — the chart renders them with `tpl`, so you can also reference template functions and `.Release`/`.Values` inside them.
- The equivalent `global.customVolumes`/`global.customVolumeMounts` values exist too, for sharing the same volumes across every product subchart when Distribution is deployed inside `jfrog-platform`.

## Deploy

```shell
helm upgrade --install distribution jfrog/distribution -f custom-volumes-values.yaml
```
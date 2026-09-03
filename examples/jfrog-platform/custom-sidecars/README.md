# Add a Custom Sidecar Container

This example shows how to run a utility container alongside a product's main container, using `customSidecarContainers` on the `jfrog-platform` umbrella chart.

See the [custom-sidecars-values.yaml](custom-sidecars-values.yaml) for the configuration example.

## How it works
- Artifactory's `customSidecarContainers` is double-nested under the platform chart — `artifactory.artifactory.customSidecarContainers` — matching `customInitContainers`, because the standalone Artifactory chart wraps its own settings in a self-named `artifactory:` block.
- Other subcharts use their own `common.customSidecarContainers` instead, since their standalone charts don't self-wrap the same way:

  | Product | Path under `jfrog-platform` |
  |---|---|
  | Artifactory | `artifactory.artifactory.customSidecarContainers` |
  | Xray | `xray.common.customSidecarContainers` |
  | Distribution | `distribution.common.customSidecarContainers` |

- Sidecars typically need their own volume/mount, added via the matching `customVolumes`/`customVolumeMounts` path for that product (see [custom-volumes-multi-product](../custom-volumes-multi-product)).

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-sidecars-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-sidecars](../../artifactory/custom-sidecars), [custom-sidecars](../../artifactory-ha/custom-sidecars) — the same mechanism on standalone Artifactory and Artifactory HA.
- [custom-init-containers](../custom-init-containers) — the init-container equivalent of this mechanism.

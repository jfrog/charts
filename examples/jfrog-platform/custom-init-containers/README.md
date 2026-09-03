# Inject Custom Init Containers

This example shows how to inject a custom init container before Artifactory's own predefined init containers when Artifactory is deployed as a subchart of `jfrog-platform`, using `artifactory.artifactory.customInitContainersBegin`.

See the [custom-init-containers-values.yaml](custom-init-containers-values.yaml) for the configuration example.

## How it works
- The key is double-nested for Artifactory — `artifactory.artifactory.customInitContainersBegin`/`customInitContainers` — following the same pattern as `license`/`resources` (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)). Other subcharts use their own single-nested `common.*` block instead:

  | Product | Path under `jfrog-platform` |
  |---|---|
  | Artifactory | `artifactory.artifactory.customInitContainersBegin` / `customInitContainers` |
  | Xray | `xray.common.customInitContainersBegin` / `customInitContainers` |
  | Distribution | `distribution.common.customInitContainersBegin` / `customInitContainers` |

- **Reserved at the platform level:** `global.customInitContainersBegin` is pre-populated by `jfrog-platform` with `{{ template "initdb" . }}` to bootstrap the bundled PostgreSQL database. Never override it — use the product-scoped key instead. This is the same warning that applies to `global.customVolumes` (see [custom-volumes-multi-product](../custom-volumes-multi-product)).

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-init-containers-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-init-containers](../../artifactory/custom-init-containers) — the standalone-chart version.
- [custom-init-containers](../../artifactory-ha/custom-init-containers) — the artifactory-ha version.
- [custom-sidecars](../custom-sidecars) — the sidecar-container equivalent of this mechanism.

# Add a Custom Sidecar Container

This example shows how to run a utility container alongside the main Artifactory container in the same pod, using `artifactory.customSidecarContainers`.

See the [custom-sidecars-values.yaml](custom-sidecars-values.yaml) for the configuration example.

## How it works
- `artifactory.customSidecarContainers` uses the same key and nesting as the standalone `artifactory` chart — a `tpl`-rendered YAML-list string, not scoped under `artifactory.primary`.
- Sidecars typically need their own volume/mount, added via `artifactory.customVolumes`/`customVolumeMounts` (see [custom-volumes](../custom-volumes)) — in this example, a ConfigMap-backed script mounted into both the sidecar and made available for it to run.
- The sidecar container is appended to the pod's existing container list; it doesn't replace or affect the main Artifactory container.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-sidecars-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-sidecars](../../artifactory/custom-sidecars), [custom-sidecars](../../jfrog-platform/custom-sidecars) — the same mechanism on standalone Artifactory and JFrog Platform.
- [custom-init-containers](../custom-init-containers) — the init-container equivalent of this mechanism.

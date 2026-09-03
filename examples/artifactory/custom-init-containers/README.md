# Inject Custom Init Containers

This example shows how to inject custom init containers before and after Artifactory's own predefined init containers, using `artifactory.customInitContainersBegin` (before) and `artifactory.customInitContainers` (after).

See the [custom-init-containers-values.yaml](custom-init-containers-values.yaml) for the configuration example.

## How it works
- Both keys are `tpl`-rendered YAML-list strings, so `{{ .Values.* }}` template expressions inside them resolve — this is the same rendering behavior as `customVolumes`/`customVolumeMounts` (see [custom-volumes](../custom-volumes)).
- `customInitContainersBegin` runs before the chart's built-in init containers; `customInitContainers` runs after.
- If deployed under `jfrog-platform` instead, avoid overriding `global.customInitContainersBegin` — the platform chart pre-populates it with `{{ template "initdb" . }}` to bootstrap the bundled PostgreSQL database, and overriding it at the `global` level breaks database initialization. Use the product-scoped key instead (see [custom-init-containers](../../jfrog-platform/custom-init-containers)).

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f custom-init-containers-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-init-containers](../../artifactory-ha/custom-init-containers) — the artifactory-ha version.
- [custom-init-containers](../../jfrog-platform/custom-init-containers) — the jfrog-platform umbrella-chart version.
- [custom-volumes](../custom-volumes) — the companion topic covering custom volumes/mounts, with the same `global.*` reservation caveat.
- [custom-sidecars](../custom-sidecars) — the sidecar-container equivalent of this mechanism.

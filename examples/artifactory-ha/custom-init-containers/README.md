# Inject Custom Init Containers

This example shows how to inject custom init containers before Artifactory HA's own predefined init containers, using `artifactory.customInitContainersBegin`.

See the [custom-init-containers-values.yaml](custom-init-containers-values.yaml) for the configuration example.

## How it works
- `artifactory.customInitContainersBegin` (before) / `artifactory.customInitContainers` (after) use the same two keys, flat under the `artifactory:` block — same as the standalone chart.
- Both keys are `tpl`-rendered YAML-list strings, so `{{ .Values.* }}` template expressions inside them resolve — this is the same rendering behavior as `customVolumes`/`customVolumeMounts` (see [custom-volumes](../custom-volumes)).
- If deployed under `jfrog-platform` instead, avoid overriding `global.customInitContainersBegin` — the platform chart pre-populates it to bootstrap the bundled PostgreSQL database (see [custom-init-containers](../../jfrog-platform/custom-init-containers)).

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-init-containers-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-init-containers](../../artifactory/custom-init-containers) — the standalone-chart version.
- [custom-init-containers](../../jfrog-platform/custom-init-containers) — the jfrog-platform umbrella-chart version.
- [custom-sidecars](../custom-sidecars) — the sidecar-container equivalent of this mechanism.

# Add a Custom Sidecar Container

This example shows how to run a utility container alongside the main Artifactory container in the same pod — for monitoring agents, log collection, or auxiliary services — using `artifactory.customSidecarContainers`.

See the [custom-sidecars-values.yaml](custom-sidecars-values.yaml) for the configuration example.

## How it works
- `artifactory.customSidecarContainers` is a `tpl`-rendered YAML-list **string**, at the same nesting depth as `customVolumes`/`customInitContainers` — use the `|` block scalar and reference template values like `{{ .Release.Name }}` inside it if needed.
- Sidecars typically need their own volume/mount, added via `artifactory.customVolumes`/`customVolumeMounts` (see [custom-volumes](../custom-volumes)) — in this example, a ConfigMap-backed script mounted into both the sidecar and made available for it to run.
- The sidecar container is appended to the pod's existing container list; it doesn't replace or affect the main Artifactory container.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f custom-sidecars-values.yaml
```

## Related
- [custom-sidecars](../../artifactory-ha/custom-sidecars), [custom-sidecars](../../jfrog-platform/custom-sidecars) — the same mechanism on Artifactory HA and JFrog Platform.
- [custom-init-containers](../custom-init-containers) — the init-container equivalent of this mechanism.

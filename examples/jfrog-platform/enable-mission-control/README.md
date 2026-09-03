# Enable Mission Control

This example shows how to enable JFrog Mission Control via `artifactory.mc.enabled`.

See the [enable-mission-control-values.yaml](enable-mission-control-values.yaml) for the configuration example.

## How it works

- Mission Control does not run as a separate pod — it runs as an embedded process inside the Artifactory pod, which is why the flag lives under `artifactory.mc.enabled` rather than a top-level subchart key.
- Mission Control requires an Enterprise+ license. Setting `mc.enabled: true` with a Pro license causes Artifactory to fail the feature check at startup.
- `mc.enabled` defaults to `false` in `stable/jfrog-platform/values.yaml` (also flagged there with an inline comment about the Pro license restriction).

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-mission-control-values.yaml
```

## Related
See [enable-mission-control](../../artifactory/enable-mission-control) and [enable-mission-control](../../artifactory-ha/enable-mission-control) for the equivalent configuration on the standalone `artifactory`/`artifactory-ha` charts (same chart-root `mc.enabled` key, no extra nesting).
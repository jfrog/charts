# Enable Artifactory Federation Service (RTFS)

This example shows how to enable the Artifactory Federation Service (RTFS) via `artifactory.rtfs.enabled`.

See the [enable-federation-values.yaml](enable-federation-values.yaml) for the configuration example.

## How it works
- `rtfs` is a chart-root key in the standalone `artifactory` chart, so under `jfrog-platform` it needs only the single `artifactory.` prefix (single-nest tier, same as `mc`/`ml`/`apptrust`) — confirmed empirically: setting `artifactory.rtfs.enabled=true` adds `jfrtfs` to the rendered `JF_ROUTER_TOPOLOGY_LOCAL_REQUIREDSERVICETYPES` env var.
- Requires Artifactory 7.104+. See [enable-federation](../../artifactory/enable-federation) for the dedicated-PostgreSQL option (`artifactory.rtfs.database`) and version requirements.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-federation-values.yaml
```

## Related
- [enable-federation](../../artifactory/enable-federation) and [enable-federation](../../artifactory-ha/enable-federation) — the equivalent configuration on the standalone `artifactory`/`artifactory-ha` charts.
- [enable-disable-platform-services](../enable-disable-platform-services) — shows the bare `rtfs.enabled` flag generically alongside `platformfederation` and the platform's other in-pod-style service toggles.
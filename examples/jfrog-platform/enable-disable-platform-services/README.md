# Enable/Disable In-Pod Platform Services

Artifactory runs several JFrog Platform services as containers inside its own pod rather than as separate deployments: `frontend`, `metadata`, `event`, `observability`, `jfconnect`, `jfconfig`, `evidence`, `onemodel` (all `enabled: true` by default), and `platformfederation`, `rtfs` (both `enabled: false` by default, gated by license tier). Each has its own `<service>.enabled` flag. This example demonstrates disabling one default-on service (`observability`, to save resources) and enabling one default-off service (`platformfederation`, an Enterprise+ feature) under the `jfrog-platform` umbrella chart — the same pattern applies to any of the other eight.

See the [enable-disable-platform-services-values.yaml](enable-disable-platform-services-values.yaml) for the configuration example.

## How it works
- Under `jfrog-platform`, these keys nest one level deeper: `artifactory.observability.enabled` / `artifactory.platformfederation.enabled`.
- They are **single-nested**, like `artifactory.mc.enabled`/`artifactory.apptrust.enabled` — **not** double-nested like `artifactory.artifactory.license.secret`. This was confirmed empirically: setting `artifactory.observability.enabled=false` removed the `observability` container from the rendered output, while `artifactory.artifactory.observability.enabled=false` had no effect at all.
- The same per-service `enabled` flag pattern applies to `frontend`, `metadata`, `event`, `jfconnect`, `jfconfig`, `evidence`, `onemodel`, and `rtfs`.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-disable-platform-services-values.yaml
```

## Related
- [enable-disable-platform-services](../../artifactory/enable-disable-platform-services) and [enable-disable-platform-services](../../artifactory-ha/enable-disable-platform-services) — the same toggle on the standalone charts, where the keys sit at chart root instead of nested under `artifactory.*`.
- [enable-apptrust](../enable-apptrust) and [enable-mission-control](../enable-mission-control) — the same "in-pod feature toggle" pattern for AppTrust and Mission Control specifically.

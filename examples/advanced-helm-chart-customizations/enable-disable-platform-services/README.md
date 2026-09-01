# Enable/Disable In-Pod Platform Services

Artifactory runs several JFrog Platform services as containers inside its own pod rather than as separate deployments: `frontend`, `metadata`, `event`, `observability`, `jfconnect`, `jfconfig`, `evidence`, `onemodel` (all `enabled: true` by default), and `platformfederation`, `rtfs` (both `enabled: false` by default, gated by license tier). Each has its own `<service>.enabled` flag. This example demonstrates disabling one default-on service (`observability`, to save resources) and enabling one default-off service (`platformfederation`, an Enterprise+ feature) — the same pattern applies to any of the other eight.

<details>
  <summary>Artifactory</summary>

`observability.enabled` / `platformfederation.enabled` are chart-root keys.

See [enable-disable-platform-services-artifactory-values.yaml](enable-disable-platform-services-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f enable-disable-platform-services-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same chart-root keys and behavior as standalone Artifactory.

See [enable-disable-platform-services-artifactory-ha-values.yaml](enable-disable-platform-services-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f enable-disable-platform-services-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

These keys nest one level deeper, under `artifactory.<service>.enabled` — single-nested like `artifactory.mc.enabled`/`artifactory.apptrust.enabled`, **not** double-nested like `artifactory.artifactory.license.secret`. This was confirmed empirically: setting `artifactory.observability.enabled=false` removed the `observability` container from the rendered output, while `artifactory.artifactory.observability.enabled=false` had no effect at all.

See [enable-disable-platform-services-jfrog-platform-values.yaml](enable-disable-platform-services-jfrog-platform-values.yaml).

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-disable-platform-services-jfrog-platform-values.yaml
```
</details>

## Related
- [artifactory/enable-apptrust](../../artifactory/enable-apptrust) and [jfrog-platform/enable-mission-control](../../jfrog-platform/enable-mission-control) — the same "in-pod feature toggle" pattern for AppTrust and Mission Control specifically.
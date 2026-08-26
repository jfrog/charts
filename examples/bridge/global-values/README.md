# Bridge Global Values

This example shows how to configure JFrog Bridge using the `global` values block instead of (or in addition to) the regular top-level values.

`global` values are meant for settings that are typically shared across multiple JFrog charts deployed together (for example when Bridge is deployed as part of the `jfrog-platform` chart, alongside Artifactory). Values under `global` take precedence over their equivalent top-level (service-level) values.

See the [global-values.yaml](global-values.yaml) for the configuration example.

## Precedence

For the values below, if both `global.<key>` and the top-level `<key>` are set, `global.<key>` wins:

| Global value | Equivalent top-level value | Notes |
|---|---|---|
| `global.jfrogUrl` | `jfrogUrl` | Artifactory URL |
| `global.joinKey` / `global.joinKeySecretName` | `joinKey` / `joinKeySecretName` | Join key used to connect Bridge to Artifactory |
| `global.masterKey` / `global.masterKeySecretName` | `masterKey` / `masterKeySecretName` | Unique master key |
| `global.imageRegistry` | `image.registry` (per-image) | Overrides the registry for all images |
| `global.imagePullSecrets` | `image.pullSecrets` (per-image) | Merged with existing pull secrets |
| `global.versions.<component>` | Image `tag` (per-image) | Order of preference: 1) `global.versions` 2) image tag 3) `Chart.AppVersion` |
| `global.digests.<component>` | Image `digest` (per-image) | Order of preference: 1) `global.digests` 2) image digest |
| `global.nodeSelector` | `nodeSelector` | Applies to Bridge pods |
| `global.customCertificates.enabled` | `customCertificates.enabled` | Custom certificates copied to the trusted keys directory |
| `global.extraVolumes` / `global.extraVolumeMounts` | `common.extraVolumes` / `common.extraVolumeMounts` | Both global and common entries are applied simultaneously (not mutually exclusive) |
| `global.customInitContainers` / `global.customSidecarContainers` | `common.customInitContainers` / `common.customSidecarContainers` | Both global and common entries are applied simultaneously (not mutually exclusive) |

## Deploy

Install Bridge with the following command:

```shell
helm upgrade --install bridge jfrog/bridge -f global-values.yaml
```

## When to use global values

Use `global` values when deploying Bridge together with other JFrog charts (for example via the `jfrog-platform` umbrella chart) and you want a single place to set values like `jfrogUrl`, `joinKey`, `masterKey`, `imageRegistry` or image versions that should apply consistently across all the deployed services.

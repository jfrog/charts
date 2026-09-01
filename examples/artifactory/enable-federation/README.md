# Enable Artifactory Federation Service (RTFS)

This example shows how to enable the Artifactory Federation Service (RTFS) — used for timely synchronization of large volumes of artifact metadata between customer sites — via `rtfs.enabled`.

See the [enable-federation-values.yaml](enable-federation-values.yaml) for the configuration example.

## How it works
- `rtfs.enabled` is a chart-root key, `false` by default. RTFS runs as its own Deployment (not embedded in the Artifactory pod), with its own image, replica count, and probes.
- `rtfs.replicaCount` is aligned with `artifactory.replicaCount` at chart defaults but can be scaled independently by setting it explicitly.
- RTFS always uses PostgreSQL for its own metadata and queues. By default it shares Artifactory's database; from Artifactory 7.146.7+ you can point it at a dedicated PostgreSQL instance via `rtfs.database` (inline credentials or `rtfs.database.secrets.*` Kubernetes Secret references) — see the commented-out block in the values file.
- Requires Artifactory 7.104+ (7.111+ for native Linux installers). Certificate handling for RTFS's own trust store depends on your Artifactory version: below 7.133.4 requires a CA-signed certificate; 7.133.4+ also supports self-signed or custom-CA certificates.
- After enabling, verify with `GET <platform-url>/rtfs/api/v1/system/liveness` (or the legacy `/artifactory/service/rtfs/...` path on older versions). Existing Federated repositories must be migrated to RTFS separately — enabling this value only deploys the service.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f enable-federation-values.yaml
```

> The values file also includes placeholder `global.masterKey`/`global.joinKey` and `nginx.tlsSecretName` — every fresh Artifactory install requires these regardless of this example's topic. Replace them with your own generated keys and a real TLS secret before deploying to a real cluster.

## Related
- [enable-federation](../../artifactory-ha/enable-federation) and [enable-federation](../../jfrog-platform/enable-federation) — the equivalent configuration on the HA and platform charts.
- [advanced-helm-chart-customizations/enable-disable-platform-services](../../advanced-helm-chart-customizations/enable-disable-platform-services) — shows the bare `rtfs.enabled` flag generically alongside the platform's other in-pod-style service toggles; this example is the fuller, dedicated federation setup.
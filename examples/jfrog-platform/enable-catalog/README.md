# Enable Catalog

This example shows how to enable JFrog Catalog via `catalog.enabled`.

See the [enable-catalog-values.yaml](enable-catalog-values.yaml) for the configuration example.

## How it works

- Catalog is not supported as a standalone feature: `stable/jfrog-platform/templates/keys-warnings.yaml` calls `fail` at template time if `catalog.enabled: true` while `xray.enabled: false`, so the install/upgrade aborts outright rather than deploying a broken configuration.
- Catalog stores its working data on an ephemeral `emptyDir` volume, not a PersistentVolumeClaim — data does not survive pod rescheduling by design.
- Requires Artifactory 7.90.12+ and Xray 3.107.0+.
- For Valkey-backed response caching on top of this base configuration, see the existing [xray-with-catalog-valkey-cache](../xray-with-catalog-valkey-cache) example — Valkey itself runs as a Sentinel-managed HA cluster inside the Xray subchart, not a single pod.

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-catalog-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```
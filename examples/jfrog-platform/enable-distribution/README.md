# Enable Distribution

This example shows how to enable JFrog Distribution via `distribution.enabled`.

See the [enable-distribution-values.yaml](enable-distribution-values.yaml) for the configuration example.

## How it works

- `distribution.enabled: true` turns on the `distribution` subchart (disabled by default) and its release, edge-node, and federation features.
- Distribution requires an Enterprise+ license.
- Inside `jfrog-platform`, Distribution shares the platform's bundled PostgreSQL by default (`distribution.postgresql.enabled: false`, with `distribution.database.url` resolved automatically against the shared instance) — you don't need a separate external database unless you've disabled the platform's bundled Postgres entirely.
- `distribution.unifiedUpgradeAllowed` is already `true` by default. It's an upgrade-only gate for migrating from legacy Distribution 1.x/2.x, not something you need to set for a fresh install.

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-distribution-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```
# Upgrade Gates: `gaUpgradeReady` and `databaseUpgradeReady`

The `jfrog-platform` chart refuses to proceed with certain upgrades unless you explicitly acknowledge them. This example shows the two acknowledgment flags and a related pitfall: two now-removed product toggles that will abort the install entirely if left in an older values file.

See the [upgrade-gates-values.yaml](upgrade-gates-values.yaml) for the configuration example.

## How it works

- `gaUpgradeReady: true` must be passed when upgrading an existing `jfrog-platform` release that is already at version 10.0.0 or later. It's a deliberate acknowledgment gate, not a feature flag — leave it `false` (the default) for a fresh install.
- `databaseUpgradeReady: true` must be passed when upgrading the bundled PostgreSQL across a major version boundary:
  - Upgrading from a chart version older than 10.18.x whose `postgresql.image.tag` was on the 13.x line: first pin `postgresql.image.tag` to your current tag, set `databaseUpgradeReady: true`, then upgrade.
  - Upgrading from chart version 10.18.x or later: just set `databaseUpgradeReady: true`.
- `insight.enabled` and `pipelines.enabled` were valid product toggles on chart 10.x. On chart 11.x these products were removed entirely — leaving either key (at any value, including `false`) in your values file causes the install/upgrade to abort. Remove the keys outright rather than setting them to `false`.

## Deploy

```console
# Fresh install: omit both gate flags entirely (they default to false)
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f upgrade-gates-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY

# Upgrading an existing >=10.0.0 release, database already on the current major version:
helm upgrade jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform \
  -f upgrade-gates-values.yaml \
  --set gaUpgradeReady=true \
  --set databaseUpgradeReady=true
```

## Notes

- These flags are upgrade-time acknowledgments, not persistent configuration — most teams pass them via `--set` on the upgrade command itself rather than committing `true` into a values file, so a later fresh install of the same values file doesn't skip a gate it should have hit.

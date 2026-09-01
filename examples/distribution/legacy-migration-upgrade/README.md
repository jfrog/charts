# Legacy Migration Upgrade (`unifiedUpgradeAllowed`)

This example shows `unifiedUpgradeAllowed`, a chart-root value with no default that Distribution requires on **every** install or upgrade, and `distribution.migration.enabled`, which runs a one-time migration job for pre-2.x data.

See the [legacy-migration-upgrade-values.yaml](legacy-migration-upgrade-values.yaml) for the configuration example.

## How it works

- `unifiedUpgradeAllowed` has no default in `values.yaml` — the chart's StatefulSet template calls Helm's `required` function on it, so a fresh install fails immediately with a "STOP! UPGRADE from Distribution 1.x currently not supported!" error unless you set it explicitly. This is true for every install, not just upgrades — set `unifiedUpgradeAllowed: true` once you've confirmed you are not upgrading from a Distribution 1.x release.
- `distribution.migration.enabled: true` additionally runs a migration init container, but only when Helm detects an actual upgrade (`.Release.IsUpgrade`) — on a fresh install this flag has no effect. Use it only when upgrading an existing Distribution 2.x release that still has pre-migration data.
- Rolling back past a completed migration is not supported — take a database backup before upgrading with `migration.enabled: true`.

## Deploy

```shell
helm upgrade --install distribution jfrog/distribution -f legacy-migration-upgrade-values.yaml
```
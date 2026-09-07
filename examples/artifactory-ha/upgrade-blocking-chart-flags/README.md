# Chart Flags That Block an Upgrade

Most wrong values in the JFrog charts are silently ignored, since the charts ship no values schema. A small number do the opposite and stop the deployment with a hard error. This example covers `splitServicesToContainers` and `waitForDatabase` on the HA chart — the same two flat, top-level keys as the standalone `artifactory` chart.

See the [upgrade-blocking-chart-flags-values.yaml](upgrade-blocking-chart-flags-values.yaml) for the configuration example.

## How it works

- **`splitServicesToContainers` can no longer be `false`.** From chart releases in the `7.161.x` line, setting this to `false` aborts the install outright with `'splitServicesToContainers: false' is no longer supported...`. Remove the line entirely (the default is already `true`) rather than setting it explicitly — this is the most common cause of a values file that worked last year failing today.
- **`waitForDatabase`** (default `true`) makes each Artifactory node wait for the database to accept connections before starting, preventing a crash loop while an external database is still coming up. Set it to `false` only when something else already guarantees ordering, such as your own init container.
- Both keys stay flat at chart root, same as standalone `artifactory` — they are not scoped under `artifactory.primary` the way `resources`/`javaOpts` are (see [ha-resource-sizing](../ha-resource-sizing)).
- `databaseUpgradeReady` — the third blocking flag — is covered separately; see Related below.

## Deploy

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f upgrade-blocking-chart-flags-values.yaml
```

## Related

- [upgrade-blocking-chart-flags](../../artifactory/upgrade-blocking-chart-flags), [upgrade-blocking-chart-flags](../../jfrog-platform/upgrade-blocking-chart-flags) — the same flags on the standalone and platform charts.
- [upgrade-gates](../../jfrog-platform/upgrade-gates) — `databaseUpgradeReady` and the platform-only `gaUpgradeReady` acknowledgment gate.

# Chart Flags That Block an Upgrade

Most wrong values in the JFrog charts are silently ignored, since the charts ship no values schema. A small number do the opposite and stop the deployment with a hard error. This example covers `artifactory.splitServicesToContainers` and `artifactory.waitForDatabase` under the `jfrog-platform` umbrella chart.

See the [upgrade-blocking-chart-flags-values.yaml](upgrade-blocking-chart-flags-values.yaml) for the configuration example.

## How it works

- **`artifactory.splitServicesToContainers` can no longer be `false`.** Single-nested under `artifactory:` (not double-nested like `license`/`resources` — see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)). From chart releases in the `7.161.x` line, setting this to `false` aborts the install outright. Remove the line entirely (the default is already `true`) rather than setting it explicitly.
- **`artifactory.waitForDatabase`** defaults to `false` under `jfrog-platform` — the opposite default from the standalone `artifactory` chart (`true`), because the platform chart already manages startup ordering itself via its own init containers. Only flip it to `true` if you've disabled that built-in ordering.
- `databaseUpgradeReady` — the third blocking flag — stays fully top-level (no `artifactory.` prefix at all) even under the umbrella chart, and is covered together with the platform-only `gaUpgradeReady` gate in [upgrade-gates](../upgrade-gates).

## Deploy

```console
helm upgrade jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform -f upgrade-blocking-chart-flags-values.yaml
```

## Related

- [upgrade-blocking-chart-flags](../../artifactory/upgrade-blocking-chart-flags), [upgrade-blocking-chart-flags](../../artifactory-ha/upgrade-blocking-chart-flags) — the same flags on the standalone and HA charts.
- [upgrade-gates](../upgrade-gates) — `databaseUpgradeReady` and `gaUpgradeReady`.
- [platform-pre-upgrade-hook](../platform-pre-upgrade-hook) — the Job that runs before every upgrade and separately guards against a disabled-but-still-running Distribution.

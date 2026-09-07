# Chart Flags That Block an Upgrade

Most wrong values in the JFrog charts are silently ignored, since the charts ship no values schema. A small number do the opposite and stop the deployment with a hard error. This example covers `splitServicesToContainers` and `waitForDatabase` — the two that most often break an upgrade carried forward from an older values file.

See the [upgrade-blocking-chart-flags-values.yaml](upgrade-blocking-chart-flags-values.yaml) for the configuration example.

## How it works

- **`splitServicesToContainers` can no longer be `false`.** Artifactory runs each service in its own container; running them all in one container was supported once and is not any more. From chart releases in the `7.161.x` line, setting this to `false` aborts the install outright with `'splitServicesToContainers: false' is no longer supported...`. This is the most common cause of a values file that worked last year failing today — remove the line entirely (the default is already `true`) rather than setting it explicitly.
- **`waitForDatabase`** (default `true`) makes Artifactory wait for the database to accept connections before starting, preventing a crash loop while an external database is still coming up. Set it to `false` only when something else already guarantees ordering, such as your own init container.
- `databaseUpgradeReady` — the third blocking flag — is covered separately; see [Related](#related) below, since it's a deliberate upgrade acknowledgment rather than a removed-feature guard.
- Render before you upgrade, not after: `helm template myrelease jfrog/artifactory --values values.yaml > /dev/null && echo "validations passed"` surfaces these failures locally. `helm get values <release-name> --namespace <namespace>` shows what a live release is actually running, which is where a stale `splitServicesToContainers: false` hides.

## Deploy

```shell
helm upgrade --install artifactory jfrog/artifactory -f upgrade-blocking-chart-flags-values.yaml
```

## Related

- [upgrade-blocking-chart-flags](../../artifactory-ha/upgrade-blocking-chart-flags), [upgrade-blocking-chart-flags](../../jfrog-platform/upgrade-blocking-chart-flags) — the same flags on the HA and platform charts.
- [upgrade-gates](../../jfrog-platform/upgrade-gates) — `databaseUpgradeReady` and the platform-only `gaUpgradeReady` acknowledgment gate.

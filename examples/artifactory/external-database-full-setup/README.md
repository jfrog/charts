# External Database (Full Setup)

This example shows the full `database.*` configuration for pointing Artifactory at an external PostgreSQL instance with a custom database name — not just pinning a password on the bundled sub-chart like [postgres-password-management](../postgres-password-management), but disabling the bundled database entirely.

See the [external-database-full-setup-values.yaml](external-database-full-setup-values.yaml) for the configuration example.

## How it works
- `postgresql.enabled: false` is required for the chart to read any `database.*` value at all — leaving it `true` (the default) makes the chart silently ignore `database.*` and keep using the bundled instance.
- `database.type`/`database.driver`/`database.url`/`database.user`/`database.password` are chart-root keys (not nested under `artifactory:`).
- For credentials already stored in a Kubernetes Secret, replace `database.user`/`database.password` with `database.secrets.user`/`database.secrets.password` (each a `{name, key}` pair referencing the Secret) — see the commented block in the values file.
- Non-PostgreSQL databases (Oracle, MySQL) need the same `database.*` block plus a JDBC driver installed via `artifactory.preStartCommand`, since the official Artifactory image only ships the PostgreSQL driver — that driver-installation step is closer to a runbook than a values.yaml snippet, so it isn't demonstrated here; see the source doc's Oracle/MySQL sections if you need a non-PostgreSQL external database.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f external-database-full-setup-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also sets `nginx.https.enabled: false` to skip the mandatory TLS-secret gate for this example; use a real `nginx.tlsSecretName` in production.

## Related
See [postgres-password-management](../postgres-password-management) for pinning a password on the **bundled** PostgreSQL sub-chart instead of using an external one.
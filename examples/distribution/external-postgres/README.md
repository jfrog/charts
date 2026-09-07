# External PostgreSQL

This example shows how to point Distribution at an external PostgreSQL instance instead of the bundled `postgresql` subchart, using `postgresql.enabled` and `database.*`.

See the [external-postgres-values.yaml](external-postgres-values.yaml) for the configuration example.

## How it works

- `postgresql.enabled: false` disables the bundled PostgreSQL subchart entirely — no `postgresql-*` pod is deployed.
- `database.type`/`database.driver` tell Distribution which JDBC driver to use (`postgresql` / `org.postgresql.Driver` are the defaults, and rarely need to change).
- `database.url`, `database.user`, and `database.password` point Distribution at your external instance. If you already keep credentials in a Kubernetes Secret, use `database.secrets.user`/`database.secrets.password`/`database.secrets.url` (each referencing a `name`/`key` pair) instead of the plaintext fields.
- `unifiedUpgradeAllowed: true` is a chart-root value with no default — every install (fresh or upgrade) must set it explicitly or the chart aborts at template time.

## Deploy

```shell
helm upgrade --install distribution jfrog/distribution -f external-postgres-values.yaml
```
# External Database

By default Wingman deploys a bundled, single-replica PostgreSQL (Bitnami subchart) meant for evaluation only. This example points Wingman at an external, shared-tier PostgreSQL instance instead using `database.url`.

See the [external-database-values.yaml](external-database-values.yaml) for the configuration example.

## How it works

- `postgresql.enabled: false` is required to use an external database — the chart fails fast if both the bundled PostgreSQL and an external database are configured, so it never deploys a StatefulSet the backend would ignore anyway.
- `database.url`/`database.username`/`database.password` configure the **shared** platform database tier. For a Wingman-only ("dedicated") database instead, use `extraSystemYaml.wingman.database.*` — configuring both the shared and dedicated tiers at once also fails at template time.
- `username` is the canonical key; the older `user` key is still accepted as a backward-compatible alias but `username` wins when both are set.
- The default bundled-PostgreSQL credentials (`postgresql.auth.username: wingman`, an auto-generated password) are not used at all once `postgresql.enabled` is `false`.

## Deploy

```shell
helm upgrade --install wingman jfrog/wingman -f external-database-values.yaml
```

See the chart's [values.yaml](../../../stable/wingman/values.yaml) for the full set of configuration options.
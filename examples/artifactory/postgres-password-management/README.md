# Pin the Bundled PostgreSQL Password

This example shows how to pin an explicit password for the chart's bundled PostgreSQL sub-chart using `postgresql.auth.password`, instead of relying on the chart-generated random password.

See the [postgres-password-management-values.yaml](postgres-password-management-values.yaml) for the configuration example.

## How it works
- `postgresql.auth.password` defaults to `""`, which the bundled PostgreSQL sub-chart (Bitnami-style) resolves to an auto-generated random password on first install, stored in a chart-managed Secret.
- Setting `postgresql.auth.password` explicitly pins that password instead — required if you need a known credential for external tooling, backups, or migrating an existing database dump.
- The password is only applied on the **initial** install; changing it in `values.yaml` after the PostgreSQL StatefulSet and its Secret already exist has no effect until the Secret is manually updated (or the PVC is reset).
- If you're using an external, non-bundled database instead, set `postgresql.enabled: false` and configure the top-level `database.*` block (`type`, `driver`, `url`, `user`, `password`) instead.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f postgres-password-management-values.yaml
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.
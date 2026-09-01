# PostgreSQL Password Management

The `jfrog-platform` chart bundles PostgreSQL and pre-wires every product to a set of default credentials. Those defaults are publicly documented (not secret) — this example shows how to override the superuser password and each product's own database password before a fresh install.

See the [postgres-password-management-values.yaml](postgres-password-management-values.yaml) for the configuration example.

## How it works

- `postgresql.auth.postgresPassword` sets the password for the bundled PostgreSQL's superuser (`postgres`). This must match `global.database.adminPassword`, which is what the chart's init containers use to create each product's database and role.
- Each product also gets its own database user/password pair — for example `artifactory.database.user` / `artifactory.database.password`. Leaving these unset lets the chart auto-generate a Secret; setting them explicitly lets you pin known credentials (for example, to match an existing external secret-management workflow).
- These are only consulted the **first time** the database and roles are created. Changing them on an existing deployment does not rotate the password inside PostgreSQL — you'd need to update it there directly and then update the chart values/secret to match.

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f postgres-password-management-values.yaml
```

## Notes

- **Do not run this in production with the values shown here.** They're placeholders — generate strong, unique passwords per environment (for example with `openssl rand -base64 24`) and prefer injecting them via a pre-existing Kubernetes Secret (`global.database.secrets`) over plaintext values files where possible.
- If you're bringing your own external PostgreSQL instead of the bundled one, set `postgresql.enabled: false` and point `global.database.host`/`port`/`sslMode` at it — the password fields above only apply to the bundled database.

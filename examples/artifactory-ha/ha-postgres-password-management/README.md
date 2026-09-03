# HA PostgreSQL Password Management

This example shows how to pin the bundled PostgreSQL password for the Artifactory HA chart using `postgresql.auth.password`, instead of relying on the chart's auto-generated default.

`postgresql.auth.password` defaults to `""`. With the bundled bitnami PostgreSQL subchart, an empty password means one is auto-generated and stored in a Secret at install time — convenient, but the value isn't visible in your values.yaml and must be retrieved from the cluster if you need it later.

See the [ha-postgres-password-management-values.yaml](ha-postgres-password-management-values.yaml) for the configuration example.

## How it works

- `postgresql.auth.password` sets the password for the `postgresql.auth.username` (`artifactory` by default) database user in the bundled PostgreSQL instance.
- Leaving it empty lets the subchart generate a random password on first install and store it in a Secret named `<release-name>-postgresql`.
- Setting it explicitly makes the password deterministic across reinstalls into the same values, and lets you manage it alongside your other secrets tooling.
- This only applies when using the bundled PostgreSQL (`postgresql.enabled: true`, the default). For an external database, disable the subchart and configure `database.*` values instead.

## Deploy

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f ha-postgres-password-management-values.yaml
```

## Notes

If you already installed with an auto-generated password, retrieve it before switching to an explicit one to avoid a mismatch:
```bash
kubectl get secret --namespace artifactory-ha <release-name>-postgresql -o jsonpath="{.data.password}" | base64 -d
```
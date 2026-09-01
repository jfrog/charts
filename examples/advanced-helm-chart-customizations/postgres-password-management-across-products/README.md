# PostgreSQL Password Management Across Products

Every chart that bundles or connects to PostgreSQL exposes its own password/credentials shape — some via a `postgresql.auth.*` block for a bundled Bitnami-style subchart, some via a `database.*` block for an external instance, and `jfrog-platform` layers a superuser password on top of per-product passwords. This example collects all of them in one place so you can compare the exact key path per chart.

<details>
  <summary>Artifactory</summary>

`postgresql.auth.password` defaults to `""`, which the bundled PostgreSQL sub-chart resolves to an auto-generated random password stored in a chart-managed Secret. Setting it explicitly pins a known password instead.

See [postgres-password-management-artifactory-values.yaml](postgres-password-management-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f postgres-password-management-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same `postgresql.auth.password` key and behavior as standalone Artifactory — the bundled PostgreSQL subchart is shared across both charts.

See [postgres-password-management-artifactory-ha-values.yaml](postgres-password-management-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f postgres-password-management-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>Catalog</summary>

Catalog has no bundled database — it always points at an external PostgreSQL via `database.*`. Production deployments should use the `database.secrets.user`/`database.secrets.password` Secret-reference form rather than plaintext values (the Secret reference wins if both are set).

See [postgres-password-management-catalog-values.yaml](postgres-password-management-catalog-values.yaml).

```shell
kubectl create secret generic catalog-database-creds \
  --from-literal=db-user=<db-user> \
  --from-literal=db-password=<db-password>
helm upgrade --install catalog jfrog/catalog -f postgres-password-management-catalog-values.yaml
```
</details>

<details>
  <summary>Distribution</summary>

`postgresql.enabled: false` disables Distribution's bundled subchart in favor of an external instance configured under `database.*`. `unifiedUpgradeAllowed` is an unrelated chart-root value with no default that every Distribution install must set explicitly.

See [postgres-password-management-distribution-values.yaml](postgres-password-management-distribution-values.yaml).

```shell
helm upgrade --install distribution jfrog/distribution -f postgres-password-management-distribution-values.yaml
```
</details>

<details>
  <summary>Wingman</summary>

`postgresql.enabled: false` is mandatory when pointing Wingman at an external database via `database.url`/`database.username`/`database.password` — the chart fails at template time if both the bundled and external databases are configured.

See [postgres-password-management-wingman-values.yaml](postgres-password-management-wingman-values.yaml).

```shell
helm upgrade --install wingman jfrog/wingman -f postgres-password-management-wingman-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

`postgresql.auth.postgresPassword` sets the bundled PostgreSQL's superuser password, and must match `global.database.adminPassword` (used by init containers to create each product's database/role). Each product then gets its own user/password pair, e.g. `artifactory.database.user`/`artifactory.database.password`.

> **Security note:** the chart's default passwords are publicly documented, not secret, and the chart does not block installs that keep them. Always override these before a real deployment.

See [postgres-password-management-jfrog-platform-values.yaml](postgres-password-management-jfrog-platform-values.yaml).

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f postgres-password-management-jfrog-platform-values.yaml
```
</details>

## References
- [artifactory/postgres-password-management](../../artifactory/postgres-password-management)
- [artifactory-ha/ha-postgres-password-management](../../artifactory-ha/ha-postgres-password-management)
- [jfrog-platform/postgres-password-management](../../jfrog-platform/postgres-password-management)
- [catalog/external-database](../../catalog/external-database)
- [distribution/external-postgres](../../distribution/external-postgres)
- [wingman/external-database](../../wingman/external-database)
# JFrog Wingman Helm Chart

Below you will find the basic instructions for installing JFrog Wingman.

## Prerequisites Details

* Kubernetes 1.21+

## Chart Details

This chart does the following:

* Deploy Wingman and its router sidecar
* Deploy the JFrog Observability sidecar (self-hosted only — see `observability.enabled`)
* Optionally deploy a bundled PostgreSQL database
  (for evaluation / demo only — see `postgresql.enabled`)

## Observability Sidecar (Self-Hosted Only)

The chart deploys the JFrog Observability service as a sidecar container
alongside Wingman and the router. This sidecar ships usage metrics and log
events to Artifactory via the JFrog Platform telemetry pipeline, enabling
feature-adoption metrics to appear in Artifactory call-home and usage reports.

**Self-hosted only.** The sidecar is enabled by default
(`observability.enabled: true`) for self-hosted deployments. SaaS
environments use their own platform-level telemetry pipeline and must
set `observability.enabled: false` in their values overlay.

To disable the sidecar:

```yaml
observability:
  enabled: false
```

To pin the image version from an umbrella chart:

```yaml
global:
  versions:
    observability: "1.26.3"
```

## Requirements

* A running Kubernetes cluster
* Dynamic storage provisioning enabled
* Default StorageClass set to allow services using the default StorageClass for
  persistent storage
* A running Artifactory installation
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed
  and setup to use the cluster
* [Helm](https://helm.sh/) v3 installed

## Installing the Chart

### Add the JFrog Helm Repository

Before installing JFrog helm charts, you will need to add the
[JFrog helm repository](https://charts.jfrog.io) to your Helm client.

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Artifactory Connection Details

To connect Wingman to your Artifactory installation, you will need to use a join
key. To learn how to retrieve the connection details of your Artifactory
installation (join key and JFrog URL) from the UI, see
[Viewing the Join Key](https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey).

### Initiate Installation

Provide a join key and the JFrog URL as parameters to the Wingman chart
installation. Use the release name `jfrog-platform-wingman` to align
Wingman's rendered resource names (Deployment, Service, Secret, bundled
PostgreSQL StatefulSet) with the JFrog Platform `jfrog-platform-*`
convention used by Artifactory, Xray, and the bundled platform
PostgreSQL.

```bash
helm upgrade --install jfrog-platform-wingman \
  --set joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY> \
  --set jfrogUrl=<YOUR_PREVIOUSLY_RETRIEVED_BASE_URL> \
  jfrog/wingman \
  --namespace wingman --create-namespace
```

## Database Configuration

Wingman supports three database options. The first option that is configured
wins (precedence: Dedicated DB → Artifactory Shared DB → Wingman Bundled DB).

**Default behavior:** `postgresql.enabled` is `true` by default — a fresh
`helm install` with no overrides brings up the bundled PostgreSQL
StatefulSet, suitable for evaluation/demo installs. **Production deployments
that bring their own external database (dedicated or shared) MUST
explicitly set `postgresql.enabled: false`**; the chart fails fast at
template time on the conflict so a useless bundled StatefulSet is never
deployed alongside your real database.

**One tier at a time.** The chart also rejects configurations that mix a
dedicated Wingman database with a shared platform database — the backend
resolver would silently pick the dedicated tier and ignore the shared one,
so the chart fails fast and asks you to remove one tier explicitly.

Chart-level external-DB inputs (`.Values.database.{url,user,password}`)
flow as `JF_SHARED_DATABASE_{URL,USERNAME,PASSWORD}` env vars sourced from
the unified platform Secret. Bundled PG (`postgresql.enabled=true`) writes
the deterministic URL + username straight into `shared.database.*` of the
rendered `system.yaml`. Operators wanting a dedicated, Wingman-only DB
target can override at the `wingman.database` tier via `extraSystemYaml` —
the backend resolver picks the dedicated tier over the shared tier.

In every option below, both `postgresql://` and `jdbc:postgresql://` URL
prefixes are accepted.

### Dedicated DB (recommended for production)

A PostgreSQL instance owned by Wingman alone. Configure it via
`extraSystemYaml.wingman.database` so the resolver routes traffic to this
dedicated tier even if Artifactory's shared DB is also configured.

**Option A — URL + credentials as separate fields:**

```yaml
extraSystemYaml:
  wingman:
    database:
      url: postgresql://db.example.com:5432/wingman
      user: wingman
      password: <pwd>
```

**Option B — discrete fields (no URL):**

```yaml
extraSystemYaml:
  wingman:
    database:
      host: db.example.com
      port: 5432
      name: wingman
      user: wingman
      password: <pwd>
```

**Option C — credentials from a Kubernetes Secret (recommended for
production):** keep the connection details in `extraSystemYaml.wingman.database`
and inject the password through a `JF_WINGMAN_DATABASE_PASSWORD` env var.
`JF_*` env vars take precedence over `system.yaml` values, so you can mix
and match.

```yaml
extraSystemYaml:
  wingman:
    database:
      url: postgresql://db.example.com:5432/wingman
      user: wingman
extraEnvironmentVariables:
  - name: JF_WINGMAN_DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: wingman-db-creds
        key: password
```

**Quick external DB via chart shortcuts:** for the common case of a
single external Postgres, set `.Values.database.url` directly. The chart
delivers `JF_SHARED_DATABASE_URL` (and optional `JF_SHARED_DATABASE_USERNAME`
/ `JF_SHARED_DATABASE_PASSWORD`) from the unified platform Secret.
`system.yaml` only carries `shared.database.type` and `driver` on this
path; the URL/username/password travel exclusively as Secret-sourced env
vars.

```yaml
database:
  url: postgresql://db.example.com:5432/wingman
  user: wingman
  password: <pwd>
```

The legacy discrete fields (`database.host` / `port` / `name`) have been
removed; setting any of them now fails fast at template time with a
migration hint. Operators who need discrete-field input keep using
`extraSystemYaml.wingman.database.{host,port,name,user}` — the dedicated
tier reader supports discrete fields.

### Artifactory Shared DB (reuse Artifactory's PostgreSQL)

Point Wingman at Artifactory's existing `shared.database` block by injecting
it through `extraSystemYaml`. Same shape as Artifactory's own `system.yaml`
— URL holds host/port/db, credentials are separate fields.

```yaml
extraSystemYaml:
  shared:
    database:
      url: jdbc:postgresql://db.example.com:5432/artifactory
      username: artifactory
      password: <pwd>
```

For production, inject the password via a Kubernetes Secret instead of
inline:

```yaml
extraSystemYaml:
  shared:
    database:
      url: jdbc:postgresql://db.example.com:5432/artifactory
      username: artifactory
extraEnvironmentVariables:
  - name: JF_SHARED_DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: artifactory-db-creds
        key: password
```

### Wingman Bundled DB (evaluation / demo only)

Enable the bundled PostgreSQL subchart (Bitnami). Not suitable for
production. Subchart values live under `postgresql.*` in `values.yaml`
and follow the [Bitnami schema](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
(e.g. `postgresql.auth.*`, `postgresql.primary.persistence.*`,
`postgresql.primary.service.ports.postgresql`).

```bash
helm upgrade --install jfrog-platform-wingman \
  --set postgresql.enabled=true \
  jfrog/wingman
```

**Upgrading the bundled DB:** on `helm upgrade` against a release with
`postgresql.enabled: true`, the chart fails fast unless
`databaseUpgradeReady: true` is set. Pin `postgresql.image.tag` to the
currently running version first; see `files/postgresUpgradeWarning.txt`
for the full procedure.

See `values.yaml` (Database section) for the full knob reference and
`templates/NOTES.txt` for runtime warnings emitted at install time.

## Secrets

The chart renders a single chart-owned Secret per release:

* `<release>-wingman-unified-secret` — carries `system.yaml` (under
  `stringData`), `master-key`, `join-key`, `database-password` (when
  `database.password` is set inline), and any extras declared under
  `createSecret.values`.

When the bundled PostgreSQL is enabled (`postgresql.enabled=true`),
the Bitnami subchart additionally renders its own Secret
(`<release>-postgresql`) holding the database password. The chart never
duplicates that key into the unified Secret; Wingman reads it directly
via `secretKeyRef` (see `wingman.databaseEnvVars` in `_helpers.tpl`).

If you supply your own pre-built `system.yaml` Secret via
`systemYamlOverride.existingSecret`, the unified Secret is still
rendered (for `master-key` / `join-key` / extras) but its
`stringData.system.yaml` entry is omitted; the deployment mounts your
external Secret instead.

## Uninstalling Wingman

**IMPORTANT:** Uninstalling Wingman using the commands below will also delete
your data volumes and you will lose all of your data. You must back up all this
information before deletion.

To uninstall Wingman use the following command. The `app=wingman`
selector comes from the chart's `podLabels.app` (`values.yaml`) and is
independent of the release name — do not rewrite it to match a custom
release name.

```bash
helm uninstall jfrog-platform-wingman --namespace wingman \
  && sleep 90 \
  && kubectl delete pvc -l app=wingman
```

# Wingman Helm chart changelog

All changes to this chart are documented in this file.

**Switch initContainer image from ubi-minimal to jfrog/echo-mini.**
Aligns with artifactory/xray charts. Tag `20260728`.

**Custom CA certificate support for self-hosted deployments.**
Set `customCertificates.enabled: true` and `customCertificates.certificateSecretName`
to a Secret containing operator-provided `.crt`/`.pem` CA files (or a `tls.crt`
from a TLS-type Secret); a new `copy-custom-certificates` init container copies
them into both var/etc/security/keys/trusted (Wingman's Python HTTP clients)
and var/data/router/keys/trusted (the jfrog router sidecar). Both fields can
also be set via the umbrella chart's `global.customCertificates`; the local
value wins when both are set.

**Conformance with the `jfrog-platform` umbrella chart (WNGM-4795).**
Wingman now installs cleanly as a subchart of the default
`jfrog-platform` umbrella. Five convention gaps were closed:
(1) the template-string globals `global.jfrogUrl` and `database.url`
are now run through `tpl`, so the router's `JF_SHARED_JFROGURL` and the
unified Secret's `db-url` carry resolved values rather than the literal
`{{ … }}` string; (2) `global.customInitContainersBegin` is now treated
as a YAML list of sibling init containers (prepended before
`copy-system-yaml`) instead of a shell snippet spliced into the
`copy-system-yaml` bash command, matching artifactory/xray/distribution;
(3) `global.customVolumes` is now merged into the pod's `volumes:` (the
companion volume definitions for `customInitContainersBegin`); (4) the
unified Secret now publishes `db-user` / `db-password` under the umbrella
naming convention (the legacy `db-username` / `database-password` keys are
dual-emitted for one release of backward-compat); and (5) a new opt-in
`wait-for-artifactory` init container (`waitForArtifactory`, default
`true`) polls `<jfrogUrl>/router/api/v1/system/readiness` before startup
so the router no longer crash-loops while artifactory and the bundled
PostgreSQL come up in parallel. Operators running wingman standalone with
no JFrog Platform fronting it should set `waitForArtifactory: false`.
Because `waitForArtifactory` defaults to `true`, the chart now fails fast
at install time when it is `true` but no `jfrogUrl` is set (rather than
hanging in `Init`); set `jfrogUrl` or `waitForArtifactory: false`.

**BREAKING CHANGE (WNGM-4795): `global.customInitContainersBegin` is now a
YAML list of init containers, not a shell snippet.** Previously the value
was spliced into the `copy-system-yaml` container's bash `command`; it is
now rendered as sibling init containers. Migration: any operator passing a
shell snippet to `global.customInitContainersBegin` must replace it with a
YAML list of init-container definitions, or move shell setup into
`copy-system-yaml` another way. A shell snippet left in place will be
injected as literal YAML and rejected by Kubernetes at apply time.

**JFOB observability probe scheme now adapts to `router.tlsEnabled`
(WNGM-3978).** The JFOB sidecar's `livenessProbe` and `readinessProbe`
previously hardcoded `scheme: HTTP`, which returned 404 when the
router was configured with TLS. They now use the same `wingman.scheme`
helper the router's own probes already use. No operator action
required.

**New install convention: release name `jfrog-platform-wingman`
(WNGM-3976).** Wingman now installs under release name
`jfrog-platform-wingman` so its resources render as
`jfrog-platform-wingman-*`, aligned with the JFrog Platform
`jfrog-platform-*` convention (matching `jfrog-platform-artifactory`,
`jfrog-platform-postgresql`, etc.). The JFrog-shipped SH install path
(CI, install docs, NOTES) uses this name; operators self-installing
the chart should adopt the same convention. The chart does not enforce
a `fullnameOverride` — operators retain the option to pick a different
release name when local naming conflicts require it, but the supported
default is `jfrog-platform-wingman`. No chart-template changes are
required — `wingman.fullname` already keys off `.Release.Name`.
Existing releases installed as `wingman` keep working; this is a
release-name convention, not a chart breaking change.

`helm upgrade` cannot rename an existing release:
`Deployment.spec.selector` and the bundled PostgreSQL StatefulSet
selector are immutable, and both selector labels key off the release
name. The selector-update patch is rejected by Kubernetes, so
uninstall+reinstall is required to adopt the new name. Operators must
`helm uninstall wingman` and reinstall under the new release name.
Back up any data first; on uninstall, the bundled PostgreSQL PVC
(`data-wingman-postgresql-0`) is left behind by default and is not
reattached by the new `jfrog-platform-wingman-postgresql-0`
StatefulSet — back up the database, then delete the orphan PVC.
External dashboards, alerts, or queries keyed on
`app.kubernetes.io/instance=wingman` need to be updated to
`app.kubernetes.io/instance=jfrog-platform-wingman`.

**Breaking: chart renamed from `wingman-ai-app` to `wingman`.**
The Helm chart, the Kubernetes Service, the pod label
`app.kubernetes.io/name`, and the published Docker image
(`jfrog/ai-app-wingman` → `jfrog/wingman`) all flip in lock-step
in this release. Because Kubernetes treats `Deployment.spec.selector`
as immutable, **`helm upgrade` from a release installed via the old
`wingman-ai-app` chart will fail** with a `field is immutable` error.
Operators must `helm uninstall` the existing release and `helm install`
the new chart. See `README.md` ("Migration from chart 0.X
(`wingman-ai-app`) → 0.Y (`wingman`)") for the back-up / uninstall /
install runbook. Any external dashboards, alerts, or queries keyed on
`app=wingman-ai-app` (or `wingman-ai-app-*`) need to be updated to the
new label values; the chart-level rename is a label flip, not a
data migration.

**JFrog Observability sidecar (self-hosted only, WNGM-3832).** The chart
now deploys the JFrog Observability service as a sidecar container alongside
Wingman and the router. The sidecar ships usage metrics and log events to
Artifactory via the JFrog Platform telemetry pipeline, enabling
feature-adoption metrics in Artifactory call-home and usage reports.

Enabled by default (`observability.enabled: true`) for self-hosted
deployments. SaaS environments use their own platform-level telemetry
pipeline; `infra-core-config` sets `observability.enabled: false` for
every SaaS environment, and SaaS additionally disables event emission
at the backend via `extraSystemYaml.wingman.events.enabled: false` —
no chart-side `fail` gate is rendered, so the chart stays minimal.

New values introduced under `observability.*`:

- `observability.enabled` — enable/disable the sidecar (default: `true`)
- `observability.image.*` — registry, repository, tag, pullPolicy
- `observability.resources` — CPU/memory resource requests and limits
- `observability.livenessProbe` / `observability.readinessProbe` —
  standard probe config
- `observability.extraEnvironmentVariables` — extra env vars injected into the sidecar
- `observability.customVolumeMounts` — extra volume mounts for the sidecar
- `observability.persistence.mountPath` — data directory (default: `/var/opt/jfrog/observability`)

The image tag can be pinned from an umbrella chart via
`global.versions.observability`.

**Self-hosted only: explicit consent to the JFrog Online Beta Agreement.**
On the self-hosted (SH) install path Wingman currently ships as a beta
feature; installation is now gated on the operator setting
`consentToJfrogOnlineBetaAgreement: true` in their values file (or via
`--set consentToJfrogOnlineBetaAgreement=true`). The default is
`false`, so existing SH values files carried over from earlier chart
versions must be updated. The chart fails fast at template time with
an explicit error message when the value is missing or not exactly the
YAML boolean `true` (the string `"true"`, integer `1`, and other
truthy values are intentionally rejected). No Kubernetes resources are
rendered when the consent gate fails. SaaS installs (where
`shared.deploymentMode == "saas"`, as supplied via the operator's
`systemYaml` / `extraSystemYaml`) bypass the gate entirely and are
unaffected — `infra-core-config`'s `values-jfrog-saas.yaml.j2` already
sets this on every SaaS environment.

This release adds support for installing Wingman on self-hosted JFrog
Platform Deployments (JPD), bringing the JFrog MCP Registry to
self-managed environments alongside the existing SaaS deployment.

**Dedicated Wingman database** — A PostgreSQL database used only by
Wingman. Configure it via `extraSystemYaml.wingman.database.{url,host,…}`
and load credentials from an existing Kubernetes Secret by setting
`JF_WINGMAN_DATABASE_URL` and related `JF_WINGMAN_*` keys under
`extraEnvironmentVariables` with `valueFrom.secretKeyRef`.

**Shared JFrog Platform database** — Wingman reuses the platform's
shared PostgreSQL (the same database Artifactory and the other JFrog
services use). External DSNs supplied via `.Values.database.{url,username,password}`
flow as `JF_SHARED_DATABASE_{URL,USERNAME,PASSWORD}` env vars sourced
from the unified platform Secret. `.Values.database.user` is accepted as
a backward-compatible alias for `.Values.database.username`; the canonical
key matches `shared.database.username` and the rest of the JFrog Platform.
The same alias rule applies to `wingman.database.username` /
`wingman.database.user` consumed by the backend's dedicated-tier resolver.
`system.yaml` carries only `shared.database.type` and `driver` on this
path so credentials never appear in the rendered ConfigMap-equivalent.
Bundled PG (`postgresql.enabled=true`) keeps emitting the deterministic
URL + username under `shared.database.*` and delivers the password from
the Bitnami Secret. Operators can override at the wingman tier via
`extraSystemYaml`; the backend resolver picks the dedicated tier over
the shared tier.

**Breaking:** the legacy chart-level discrete fields
`.Values.database.{host,port,name}` are removed in favor of
`.Values.database.url`. Setting any of the removed fields now fails fast
at template time with a migration hint. Operators on the dedicated tier
(`extraSystemYaml.wingman.database.{host,port,name,user}`) are unaffected.

**Bundled PostgreSQL (evaluation only)** — Set `postgresql.enabled: true`
to deploy a single-replica PostgreSQL via the Bitnami `postgresql`
subchart alongside Wingman. This option has no high availability and no
managed backups; it is for demos and evaluation, not production.

`postgresql.enabled` defaults to `true` so a fresh install with no
overrides "just works" with the bundled database. **Production clusters
that bring their own external database (dedicated or shared) MUST
explicitly set `postgresql.enabled: false`**; the chart fails fast on the
conflict so a useless bundled StatefulSet is never deployed alongside
the real database.

The chart also rejects configurations that mix a dedicated Wingman
database with a shared platform database — the backend resolver would
silently pick the dedicated tier and ignore the shared one, so
installation stops with a clear conflict-resolution hint.

If you set `postgresql.enabled: false` and do not provide a valid external
database configuration, installation stops with a clear error.

On `helm upgrade` against a release with `postgresql.enabled: true`,
the chart fails fast unless `databaseUpgradeReady: true` is set,
forcing operators to acknowledge they have pinned `postgresql.image.tag`
to the currently running version (see `files/postgresUpgradeWarning.txt`).

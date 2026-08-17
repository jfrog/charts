{{/*
Expand the name of the chart.
*/}}
{{- define "wingman.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wingman.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name from provided context.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wingman.fullnamectx" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name_ := default .Values.nameOverride .Chart.Name }}
{{- $name := default $name_ .serviceName }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wingman.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wingman.labels" -}}
helm.sh/chart: {{ include "wingman.chart" . }}
{{ include "wingman.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wingman.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wingman.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wingman.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wingman.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve imagePullSecrets, preferring global.imagePullSecrets when set.
*/}}
{{- define "wingman.imagePullSecrets" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.imagePullSecrets -}}
imagePullSecrets:
{{- toYaml $global.imagePullSecrets | nindent 2 }}
{{- else if .Values.imagePullSecrets -}}
imagePullSecrets:
{{- toYaml .Values.imagePullSecrets | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Contruct and return the Wingman application image.
*/}}
{{- define "wingman.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- if not .Values.image.registry -}}
{{ printf "%s:%s" .Values.image.repository $tag }}
{{- else -}}
{{ printf "%s/%s:%s" .Values.image.registry .Values.image.repository $tag }}
{{- end -}}
{{- end -}}

{{/*
Shared init container image (copy-system-yaml and any operator-added ones).
*/}}
{{- define "initContainers.image" -}}
{{- if not .Values.initContainers.image.registry -}}
{{ printf "%s:%s" .Values.initContainers.image.repository .Values.initContainers.image.tag }}
{{- else -}}
{{ printf "%s/%s:%s" .Values.initContainers.image.registry .Values.initContainers.image.repository .Values.initContainers.image.tag }}
{{- end -}}
{{- end -}}

{{/*
Return the proper router image name
*/}}
{{- define "router.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.router.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper observability image name.
global.versions.observability overrides observability.image.tag when set
(umbrella-chart pinning pattern).
*/}}
{{- define "observability.image" -}}
{{- $tag := .Values.observability.image.tag -}}
{{- if and .Values.global .Values.global.versions .Values.global.versions.observability -}}
{{- $tag = .Values.global.versions.observability -}}
{{- end -}}
{{- printf "%s/%s:%s" .Values.observability.image.registry .Values.observability.image.repository $tag -}}
{{- end -}}

{{/*
Raw YAML list of sibling init containers prepended before copy-system-yaml
(umbrella hook global.customInitContainersBegin / chart-level alias).
A YAML fragment of init-container definitions — NOT a shell snippet.
*/}}
{{- define "wingman.customInitContainersBegin" -}}
{{- $global := .Values.global | default dict -}}
{{- with (or $global.customInitContainersBegin .Values.customInitContainersBegin) }}
{{ tpl . $ }}
{{- end }}
{{- end -}}

{{/*
Raw YAML list of additional init containers appended after copy-system-yaml.
Reads from the umbrella-chart hook .Values.global.customInitContainers.
*/}}
{{- define "wingman.customInitContainers" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.customInitContainers }}
{{ tpl $global.customInitContainers . }}
{{- end }}
{{- end -}}

{{/*
Shell script for the copy-custom-certificates init container. Copies
operator-provided CA certs from the mounted Secret into both trust stores:
var/etc/security/keys/trusted (Wingman's Python HTTP clients) and
var/data/router/keys/trusted (the jfrog router sidecar). Skips .key files;
a TLS-type Secret's tls.crt is renamed to ca.crt in each store, unless a
ca.crt is already present (e.g. a cert-manager CA-issuer Secret ships both
tls.crt (leaf) and ca.crt (issuing CA) — the real ca.crt must not be
clobbered by the leaf cert).
*/}}
{{- define "wingman.copyCustomCerts" -}}
for dir in {{ .Values.persistence.mountPath }}/var/etc/security/keys/trusted {{ .Values.persistence.mountPath }}/var/data/router/keys/trusted; do
  mkdir -p "$dir";
  for file in /tmp/certs/*; do
    case "$file" in *.key) continue ;; esac
    cp -v "$file" "$dir";
  done;
  if [ -f "$dir/tls.crt" ] && [ ! -f "$dir/ca.crt" ]; then
    mv "$dir/tls.crt" "$dir/ca.crt";
  fi
done
{{- end -}}

{{/*
Inject env vars from .Values.createSecret.values as secretKeyRef
entries. Each key becomes an uppercased env var whose value is sourced
from the unified platform Secret (wingman.unifiedSecretName), where the
same key was b64-encoded by templates/secrets.yaml.
*/}}
{{- define "wingman.secretEnvVars" -}}
{{- range $key, $val := .Values.createSecret.values }}
- name: {{ $key | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ include "wingman.unifiedSecretName" $ }}
      key: {{ $key }}
{{- end }}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "wingman.joinKey" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.joinKey -}}
{{- $global.joinKey -}}
{{- else if .Values.joinKey -}}
{{- .Values.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "wingman.joinKeySecretName" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.joinKeySecretName -}}
{{- $global.joinKeySecretName -}}
{{- else if .Values.joinKeySecretName -}}
{{- .Values.joinKeySecretName -}}
{{- else -}}
{{ include "wingman.unifiedSecretName" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "wingman.masterKey" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.masterKey -}}
{{- $global.masterKey -}}
{{- else if .Values.masterKey -}}
{{- .Values.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "wingman.masterKeySecretName" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.masterKeySecretName -}}
{{- $global.masterKeySecretName -}}
{{- else if .Values.masterKeySecretName -}}
{{- .Values.masterKeySecretName -}}
{{- else -}}
{{ include "wingman.unifiedSecretName" . }}
{{- end -}}
{{- end -}}

{{/*
Scheme (http/https) based on router TLS enabled/disabled
*/}}
{{- define "wingman.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value. tpl'd because the umbrella ships global.jfrogUrl
as a template string (e.g. '{{ include "jfrog-platform.jfrogUrl" . }}').
*/}}
{{- define "wingman.jfrogUrl" -}}
{{- $global := .Values.global | default dict -}}
{{- if $global.jfrogUrl -}}
{{- tpl $global.jfrogUrl . -}}
{{- else if .Values.jfrogUrl -}}
{{- tpl .Values.jfrogUrl . -}}
{{- end -}}
{{- end -}}

{{/*
Return the unified platform Secret name. This is the single chart-owned Secret
that carries system.yaml (under stringData; rendered unless the operator sets
systemYamlOverride.existingSecret), master-key, join-key, database-password,
and any operator-supplied credential-like extras declared under
.Values.createSecret.values.

The name is always release-scoped (via wingman.fullname) to avoid
cross-release collisions in shared namespaces.
*/}}
{{- define "wingman.unifiedSecretName" -}}
{{- printf "%s-unified-secret" (include "wingman.fullname" .) -}}
{{- end -}}

{{/*
Mirror of Bitnami's common.names.fullname computed in the postgresql
subchart context — i.e. the actual name Bitnami uses for the primary
Service / StatefulSet / Secret of the bundled PG (no replication).
We can't `include` the subchart helper from the parent so we reproduce
the logic; honors .Values.global.postgresql.fullnameOverride when set,
matching Bitnami's postgresql.v1.chart.fullname helper.
*/}}
{{- define "wingman.bundledPostgresqlFullname" -}}
{{- $global := .Values.global | default dict -}}
{{- $globalPg := $global.postgresql | default dict -}}
{{- if $globalPg.fullnameOverride -}}
{{- $globalPg.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := "postgresql" -}}
{{- $releaseName := regexReplaceAll "(-?[^a-z\\d\\-])+-?" (lower .Release.Name) "-" -}}
{{- if contains $name $releaseName -}}
{{- $releaseName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Bitnami's PG Secret name. Defaults to the subchart fullname; honors
auth.existingSecret (and global.postgresql.auth.existingSecret) when
operator brings their own.
*/}}
{{- define "wingman.bundledPostgresqlSecretName" -}}
{{- $global := .Values.global | default dict -}}
{{- $globalPg := $global.postgresql | default dict -}}
{{- $globalAuth := $globalPg.auth | default dict -}}
{{- $auth := (.Values.postgresql.auth | default dict) -}}
{{- if $globalAuth.existingSecret -}}
{{- $globalAuth.existingSecret -}}
{{- else if $auth.existingSecret -}}
{{- $auth.existingSecret -}}
{{- else -}}
{{- include "wingman.bundledPostgresqlFullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Normalize .Values.extraSystemYaml to a dict.

The chart documents extraSystemYaml as a YAML mapping (see values.yaml:
`extraSystemYaml: {}`), but operators frequently provide it as a `|`-block
string by analogy with .Values.systemYaml (the full-override slot, which
IS a string). Without normalization a string-form value cannot be merged
by mergeOverwrite — every consumer (dedicated/shared DB detection,
system.yaml render) silently drops the operator's overlay, producing a
chart that ignores their intent: a configured shared DB falls through
to the bundled PostgreSQL, and the overlay never lands in the rendered
Secret.

Accept both forms:
  - dict (or null/empty)            -> use as-is (default to empty dict)
  - string (e.g. `extraSystemYaml: |`) -> tpl + fromYaml, mirroring how
    .Values.systemYaml is parsed in wingman.operatorDbConfig
  - any other type                  -> fail with an actionable message
*/}}
{{- define "wingman.extraSystemYamlDict" -}}
{{- $raw := .Values.extraSystemYaml -}}
{{- if not $raw -}}
{{- dict | toYaml -}}
{{- else if kindIs "string" $raw -}}
{{- tpl $raw . | fromYaml | default dict | toYaml -}}
{{- else if kindIs "map" $raw -}}
{{- $raw | toYaml -}}
{{- else -}}
{{- fail (printf ".Values.extraSystemYaml must be a YAML mapping or a string, got %s" (kindOf $raw)) -}}
{{- end -}}
{{- end -}}

{{/*
Operator-supplied system.yaml merged across both input slots:
  - .Values.systemYaml         (string, full-override; the SaaS path
                                consumed by _system-yaml-render.tpl)
  - .Values.extraSystemYaml    (string-or-map; the SH overlay; overrides
                                .Values.systemYaml on key conflict)

Returns a YAML string consumers `fromYaml`-decode. Centralised so we don't
re-tpl the systemYaml blob and re-merge the extra dict on every consumer
(wingman.operatorDbConfig, wingman.deploymentMode, …).
*/}}
{{- define "wingman.mergedSystemYaml" -}}
{{- $operatorSys := dict -}}
{{- if .Values.systemYaml -}}
{{- $operatorSys = tpl .Values.systemYaml . | fromYaml | default dict -}}
{{- end -}}
{{- $extra := include "wingman.extraSystemYamlDict" . | fromYaml | default dict -}}
{{- mergeOverwrite (deepCopy $operatorSys) $extra | toYaml -}}
{{- end -}}

{{/*
Introspect operator-provided system.yaml configuration.

Reads the merged operator system.yaml (wingman.mergedSystemYaml — see
that helper for the merge contract) and extracts the wingman.database
and shared.database dicts. Emits a YAML map with two keys (wingmanDb,
sharedDb), each possibly empty. Used by the external-DB-signal
detectors (wingman.dedicatedWingmanDbConfigured,
wingman.sharedDbConfigured) which in turn feed
templates/validations.yaml's fail-fast check for the misconfiguration
where postgresql.enabled=false AND no external database is configured.

Tier precedence: dedicated (wingman.database) > shared (shared.database)
> bundled PostgreSQL. Whether the bundled PG (Bitnami subchart) is
deployed is governed solely by .Values.postgresql.enabled.
*/}}
{{- define "wingman.operatorDbConfig" -}}
{{- $merged := include "wingman.mergedSystemYaml" . | fromYaml | default dict -}}
{{- $wingmanDb := dig "wingman" "database" (dict) $merged -}}
{{- $sharedDb := dig "shared" "database" (dict) $merged -}}
{{- dict "wingmanDb" $wingmanDb "sharedDb" $sharedDb | toYaml -}}
{{- end -}}

{{/*
Resolve shared.deploymentMode from the merged operator system.yaml
(wingman.mergedSystemYaml — see that helper for the merge contract).
Falls back to "self_hosted" when the key is absent — that matches the
backend default in backend/app/core/config/defaults.py and the
SH-by-default posture of the chart (operators on the SH path
typically don't set deploymentMode at all and rely on the backend
default).

Used by the JFrog Online Beta Agreement consent gate in
templates/wingman-validations.yaml so the gate only enforces on
non-SaaS installs (SH operator deployments). On SaaS the gate is a
no-op because infra-core-config's values-jfrog-saas.yaml.j2 always
sets shared.deploymentMode: "saas" inside the systemYaml string blob.
*/}}
{{- define "wingman.deploymentMode" -}}
{{- $merged := include "wingman.mergedSystemYaml" . | fromYaml | default dict -}}
{{- dig "shared" "deploymentMode" "self_hosted" $merged -}}
{{- end -}}

{{/*
Effective enablement of the wait-for-artifactory init container. The
init container's purpose (gating startup on the platform router) only
applies on the self-hosted/umbrella path, so this helper auto-disables
on SaaS regardless of .Values.waitForArtifactory — see the consumer-
site comment in templates/wingman-deployment.yaml for the rationale.

Returns the literal string "true" when enabled, empty otherwise.
Consumers (deployment + validations templates) compare with `eq … "true"`.
*/}}
{{- define "wingman.waitForArtifactoryEnabled" -}}
{{- if and .Values.waitForArtifactory (ne (include "wingman.deploymentMode" .) "saas") -}}
true
{{- end -}}
{{- end -}}

{{/*
Canonical URL for the JFrog Online Beta Agreement.

Single source of truth, referenced by:
  - the consent gate failure body in
    files/betaAgreementConsentRequired.txt (rendered via tpl from
    templates/wingman-validations.yaml)
  - values.yaml documentation for consentToJfrogOnlineBetaAgreement
  - the literal-URL assertion in tests/consent_test.yaml (kept in
    lockstep with this helper so a future URL change cannot drift
    silently)

The URL is owned by Legal (@oranm). Update this helper when the
canonical URL changes; consumers pick it up automatically.
*/}}
{{- define "wingman.betaAgreementUrl" -}}
https://docs.jfrog.com/installation/docs/mcp-server-beta-agreement
{{- end -}}

{{/*
Dedicated-tier detection: a dedicated Wingman DB is configured.
True when ANY of the following supplies a DB target at the wingman tier:
  - operator systemYaml / extraSystemYaml sets wingman.database.{url,host}
  - .Values.extraEnvironmentVariables contains JF_WINGMAN_DATABASE_URL
    or JF_WINGMAN_DATABASE_HOST (operators routing credentials through
    a K8s Secret via secretKeyRef)

Note: .Values.database.{url,host} are NOT dedicated-tier signals — the
chart routes those into shared.database.url at the shared tier, which is
detected by wingman.sharedDbConfigured.

Matching the env-var surface prevents the chart from deploying a
useless bundled PostgreSQL when the backend will ignore it at runtime
(JF_* env vars take precedence over system.yaml in
ConfigurationManager). JF_WINGMAN_DATABASE_PASSWORD alone is NOT a
detection signal: without URL or HOST it cannot configure a
connection.
*/}}
{{- define "wingman.dedicatedWingmanDbConfigured" -}}
{{- $op := include "wingman.operatorDbConfig" . | fromYaml -}}
{{- $w := $op.wingmanDb -}}
{{- $hasJfEnv := false -}}
{{- range (.Values.extraEnvironmentVariables | default list) -}}
{{- if or (eq .name "JF_WINGMAN_DATABASE_URL") (eq .name "JF_WINGMAN_DATABASE_HOST") -}}
{{- $hasJfEnv = true -}}
{{- end -}}
{{- end -}}
{{- if or $w.url $w.host $hasJfEnv -}}
true
{{- end -}}
{{- end -}}

{{/*
Shared-tier detection: a shared DB is configured.
True when ANY of the following supplies a shared DB target:
  - operator systemYaml / extraSystemYaml sets shared.database.url
  - .Values.database.url — chart-level shortcut for an external DSN that
    the chart wires into shared.database via the JF_SHARED_DATABASE_URL
    env var
  - .Values.extraEnvironmentVariables contains JF_SHARED_DATABASE_URL
    (operators routing the shared DSN through a K8s Secret via
    secretKeyRef — symmetric with the dedicated-tier
    JF_WINGMAN_DATABASE_URL path)

JF_SHARED_DATABASE_HOST is intentionally NOT a detection signal — the
backend resolver only consumes shared.database.url on the shared tier,
so detecting JF_SHARED_DATABASE_HOST here would skip the bundled
PostgreSQL without giving the backend a usable DSN, leaving the pod
with no database at all.

Matching the env-var surface prevents the chart from deploying a
useless bundled PostgreSQL when the backend will ignore it at runtime
(JF_* env vars take precedence over system.yaml in
ConfigurationManager).
*/}}
{{- define "wingman.sharedDbConfigured" -}}
{{- $op := include "wingman.operatorDbConfig" . | fromYaml -}}
{{- $s := $op.sharedDb -}}
{{- $hasJfEnv := false -}}
{{- range (.Values.extraEnvironmentVariables | default list) -}}
{{- if eq .name "JF_SHARED_DATABASE_URL" -}}
{{- $hasJfEnv = true -}}
{{- end -}}
{{- end -}}
{{- if or $s.url .Values.database.url $hasJfEnv -}}
true
{{- end -}}
{{- end -}}

{{/*
Compose the bundled-PostgreSQL DSN for shared.database.url.

Used only when .Values.postgresql.enabled is true — the chart owns the
Bitnami subchart's Service / DB / username / password and writes the
URL directly into system.yaml. External-DB DSNs flow as
JF_SHARED_DATABASE_URL env vars sourced from the unified platform Secret
instead.

No sslmode query parameter is set: the Bitnami subchart ships with TLS
disabled on the server side by default, and the PostgreSQL driver's
default sslmode (`prefer`) negotiates plaintext when the server doesn't
offer SSL. Operators who enable TLS on the bundled PostgreSQL can
override the URL via extraSystemYaml.shared.database.url.
*/}}
{{- define "wingman.bundledDbUrl" -}}
{{- $host := include "wingman.bundledPostgresqlFullname" . -}}
{{- $primary := .Values.postgresql.primary | default dict -}}
{{- $svc := $primary.service | default dict -}}
{{- $ports := $svc.ports | default dict -}}
{{- $port := $ports.postgresql | default 5432 -}}
{{- $name := .Values.postgresql.auth.database -}}
{{- printf "postgres://%v:%v/%v" $host $port $name -}}
{{- end -}}

{{/*
Inject database env vars consumed by ConfigurationManager.

The chart routes the external-DB connection string and credentials as
JF_SHARED_DATABASE_{URL,USERNAME,PASSWORD} env vars sourced from the
unified platform Secret. system.yaml only carries shared.database.type
and driver on the external path — the URL/USERNAME/PASSWORD env vars
take precedence over system.yaml in ConfigurationManager so the backend
sees credentials only via Secret-mounted env vars (easier rotation,
no plaintext in system.yaml).

Bundled PG (postgresql.enabled=true) keeps the legacy in-system.yaml
URL emission (deterministic from the subchart's Service + auth
defaults; see wingman.bundledDbUrl) and only delivers the password
via env var from the Bitnami-managed Secret.

Skipped when the operator already supplies JF_SHARED_DATABASE_URL via
extraEnvironmentVariables — emitting our own would collide with theirs
in the pod spec (Kubernetes rejects duplicate env vars).
*/}}
{{- define "wingman.databaseEnvVars" -}}
{{- $hasOperatorSharedUrlEnv := false -}}
{{- range (.Values.extraEnvironmentVariables | default list) -}}
{{- if eq .name "JF_SHARED_DATABASE_URL" -}}
{{- $hasOperatorSharedUrlEnv = true -}}
{{- end -}}
{{- end -}}
{{- if .Values.postgresql.enabled -}}
- name: JF_SHARED_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "wingman.bundledPostgresqlSecretName" . }}
      key: password
{{- else if and .Values.database.url (not $hasOperatorSharedUrlEnv) -}}
- name: JF_SHARED_DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "wingman.unifiedSecretName" . }}
      key: db-url
{{/* `username` is canonical; `user` is a backward-compat alias. The
     unified Secret renders the db-user key from whichever is set
     (preferring username), so the env var is emitted whenever either
     field is supplied. */}}
{{- if or .Values.database.username .Values.database.user }}
- name: JF_SHARED_DATABASE_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "wingman.unifiedSecretName" . }}
      key: db-user
{{- end }}
{{- if .Values.database.password }}
- name: JF_SHARED_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "wingman.unifiedSecretName" . }}
      key: db-password
      optional: true
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Render the base system.yaml (either user-provided .Values.systemYaml
or the chart default).
*/}}
{{- define "wingman.baseSystemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}

{{/*
Merge extraSystemYaml on top of the base system.yaml. This lets umbrella
charts and overlay generators inject additional config without replacing
the entire system.yaml. The merged output is passed through tpl so Helm
template expressions in values (e.g. {{ .Release.Name }}) are evaluated.
*/}}
{{- define "wingman.finalSystemYaml" -}}
{{- $base := include "wingman.baseSystemYaml" . | fromYaml | default dict -}}
{{- $extra := include "wingman.extraSystemYamlDict" . | fromYaml | default dict -}}
{{ tpl (mergeOverwrite $base $extra | toYaml) . }}
{{- end -}}

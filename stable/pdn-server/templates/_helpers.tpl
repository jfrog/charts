{{/* vim: set filetype=mustache: */}}
{{/*
    Expand the name of the chart.
*/}}
{{- define "pdn-server.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
    Create chart name and version as used by the chart label.
*/}}
{{- define "pdn-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
    Create a default fully qualified app name.
    We truncate at 63 chars because some Kubernetes name fields
    are limited to this (by the DNS naming spec).
    If release name contains chart name it will be used as a full name.
*/}}
{{- define "pdn-server.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
    Return the proper PDN Server image name
*/}}
{{- define "pdn-server.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "appVer" .Chart.AppVersion) }}
{{- end -}}

{{/*
    Return the proper init container image name
*/}}
{{- define "pdn-server.initContainers.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initContainers.image "global" .Values.global) }}
{{- end -}}

{{/*
    Return the proper Docker Image Registry Secret Names
*/}}
{{- define "pdn-server.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.initContainers.image) "global" .Values.global) }}
{{- end -}}

{{/*
    Return podAnnotations
*/}}
{{- define "pdn-server.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) }}
{{- end }}
{{- if and .Values.metrics.enabled .Values.metrics.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.metrics.podAnnotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "pdn-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "pdn-server.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
    Resolve joinKey value
*/}}
{{- define "pdn-server.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.joinKey -}}
{{- .Values.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
    Resolve joinKeySecretName value
*/}}
{{- define "pdn-server.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.joinKeySecretName -}}
{{- .Values.joinKeySecretName -}}
{{- else -}}
{{ include "pdn-server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
    Resolve masterKey value
*/}}
{{- define "pdn-server.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.masterKey -}}
{{- .Values.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
    Resolve masterKeySecretName value
*/}}
{{- define "pdn-server.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.masterKeySecretName -}}
{{- .Values.masterKeySecretName -}}
{{- else -}}
{{ include "pdn-server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
    Resolve pdnJoinKeySecretName value
*/}}
{{- define "pdn-server.pdnJoinKeySecretName" -}}
{{- if .Values.global.pdnJoinKeySecretName -}}
{{- .Values.global.pdnJoinKeySecretName -}}
{{- else if .Values.pdnJoinKeySecretName -}}
{{- .Values.pdnJoinKeySecretName -}}
{{- else -}}
{{ include "pdn-server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
    Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "pdn-server.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
    Resolve jfrogUrl value
*/}}
{{- define "pdn-server.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfrogUrl -}}
{{- .Values.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
    Return the proper observability image name
*/}}
{{- define "observability.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.observability.image "global" .Values.global) }}
{{- end -}}

{{/*
    Return the proper router image name
*/}}
{{- define "router.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.router.image "global" .Values.global) }}
{{- end -}}

{{/*
    Custom certificate copy command
*/}}
{{- define "pdn-server.copyCustomCertsCmd" -}}
echo "Copy custom certificates to {{ .Values.persistence.mountPath }}/etc/security/keys/trusted"
mkdir -p {{ .Values.persistence.mountPath }}/etc/security/keys/trusted

for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep)
do
    if [[ -f "${file}" ]]; then
        cp -v "${file}" {{ .Values.persistence.mountPath }}/etc/security/keys/trusted
    fi
done

if [[ -f {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]]; then
    mv -v {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/tls.crt \
        {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/ca.crt
fi
{{- end -}}

{{/*
    pdnserver liveness probe
*/}}
{{- define "pdn-server.livenessProbe" -}}
{{- printf "%s" "/api/v1/system/liveness" -}}
{{- end -}}

{{/*
    pdnserver startup probe
*/}}
{{- define "pdn-server.startupProbe" -}}
{{- printf "%s" "/api/v1/system/readiness" -}}
{{- end -}}

{{/*
    Resolve pdnserver requiredServiceTypes value
*/}}
{{- define "pdn-server.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jftrk,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

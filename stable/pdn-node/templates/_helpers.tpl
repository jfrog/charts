{{/* vim: set filetype=mustache: */}}
{{/*
    Expand the name of the chart.
*/}}
{{- define "pdn-node.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
    Create a default fully qualified app name.
    We truncate at 63 chars because some Kubernetes name
    fields are limited to this (by the DNS naming spec).
    If release name contains chart name it will be used as a full name.
*/}}
{{- define "pdn-node.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
    pdnnode liveness probe
*/}}
{{- define "pdn-node.livenessProbe" -}}
{{- printf "%s" "/api/v1/system/liveness" -}}
{{- end -}}

{{/*
    pdnnode startup probe
*/}}
{{- define "pdn-node.startupProbe" -}}
{{- printf "%s" "/api/v1/system/readiness" -}}
{{- end -}}

{{/*
    Return the proper pdnnode image name
*/}}
{{- define "pdn-node.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "appVer" .Chart.AppVersion) }}
{{- end -}}

{{/*
    Return the proper init container image name
*/}}
{{- define "pdn-node.initContainers.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initContainers.image "global" .Values.global) }}
{{- end -}}

{{/*
    Return the proper Docker Image Registry Secret Names
*/}}
{{- define "pdn-node.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.initContainers.image) "global" .Values.global) }}
{{- end -}}

{{/*
    Return podAnnotations
*/}}
{{- define "pdn-node.podAnnotations" -}}
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
{{- define "pdn-node.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "pdn-node.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
    Resolve pdnJoinKeySecretName value
*/}}
{{- define "pdn-node.pdnJoinKeySecretName" -}}
{{- if .Values.pdnJoinKeySecretName -}}
{{- .Values.pdnJoinKeySecretName -}}
{{- else -}}
{{ include "pdn-node.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
    Custom certificate copy command
*/}}
{{- define "pdn-node.copyCustomCertsCmd" -}}
echo "Copy custom certificates to {{ .Values.persistence.mountPath }}/etc/security/keys/trusted"
mkdir -p {{ .Values.persistence.mountPath }}/etc/security/keys/trusted

for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep)
do
    if [[ -f "${file}" ]]; then
        cp -v "${file}" {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/
    fi
done
{{- end -}}

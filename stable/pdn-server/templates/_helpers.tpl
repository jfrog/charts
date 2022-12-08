{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pdnserver.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pdnserver.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the proper pdnnode image name
*/}}
{{- define "pdnserver.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "appVer" .Chart.AppVersion) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "pdnserver.initContainers.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initContainers.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "pdnserver.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.initContainers.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return podAnnotations
*/}}
{{- define "pdnserver.podAnnotations" -}}
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
{{- define "pdnserver.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "pdnserver.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Resolve pdnNodeJoinKey value
*/}}
{{- define "pdnserver.pdnServerJoinKey" -}}
{{- if .Values.global.pdnServerJoinKey -}}
{{- .Values.global.pdnServerJoinKey -}}
{{- else if .Values.pdnServerJoinKey -}}
{{- .Values.pdnServerJoinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "pdnserver.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.joinKeySecretName -}}
{{- .Values.joinKeySecretName -}}
{{- else -}}
{{ include "pdnserver.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve pdnNodeJoinKeySecretName value
*/}}
{{- define "pdnserver.pdnServerJoinKeySecretName" -}}
{{- if .Values.global.pdnServerJoinKeySecretName -}}
{{- .Values.global.pdnServerJoinKeySecretName -}}
{{- else if .Values.pdnServerJoinKeySecretName -}}
{{- .Values.pdnServerJoinKeySecretName -}}
{{- else -}}
{{ include "pdnserver.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "pdnserver.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "pdnserver.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.joinKey -}}
{{- .Values.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "pdnserver.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfrogUrl -}}
{{- .Values.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "pdnserver.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.masterKey -}}
{{- .Values.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "pdnserver.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.masterKeySecretName -}}
{{- .Values.masterKeySecretName -}}
{{- else -}}
{{ include "pdnserver.fullname" . }}
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
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "event.initContainers.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initContainers.image "global" .Values.global) }}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "pdnserver.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
pdnserver liveness probe
*/}}
{{- define "pdnserver.livenessProbe" -}}
{{- printf "%s" "/api/v1/system/liveness" -}}
{{- end -}}

{{/*
pdnserver readiness probe
*/}}
{{- define "pdnserver.readinessProbe" -}}
{{- printf "%s" "/api/v1/system/readiness" -}}
{{- end -}}

{{/*
Resolve pdnserver requiredServiceTypes value
*/}}
{{- define "pdnserver.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jftrk,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}
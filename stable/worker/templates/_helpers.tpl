{{/*
Expand the name of the chart.
*/}}
{{- define "worker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "worker.fullname" -}}
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
Return the proper worker image name
*/}}
{{- define "worker.image" -}}
{{ include "common.images.global.image" (dict "imageRoot" .Values.image "global" .Values.global "globalVersion" .Values.global.versions.worker "appVer" .Chart.AppVersion) }}
{{- end -}}

{{/*
Return the proper router image name
*/}}
{{- define "router.image" -}}
{{ include "common.images.global.image" (dict "imageRoot" .Values.router.image "global" .Values.global "globalVersion" .Values.global.versions.router) }}
{{- end -}}

{{/*
Return the proper initContainers image name
*/}}
{{- define "initContainers.image" -}}
{{ include "common.images.global.image" (dict "imageRoot" .Values.initContainers.image "global" .Values.global "globalVersion" .Values.global.versions.initContainers) }}
{{- end -}}

{{/*
Return the proper observability image name
*/}}
{{- define "observability.image" -}}
{{ include "common.images.global.image" (dict "imageRoot" .Values.observability.image "global" .Values.global "globalVersion" .Values.global.versions.observability) }}
{{- end -}}

{{/*
    Return the proper Docker Image Registry Secret Names
*/}}
{{- define "worker.imagePullSecrets" -}}
{{ include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.router.image .Values.initContainers.image .Values.observability.image) "context" $) }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "worker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "worker.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "worker.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve joinKey value
*/}}
{{- define "worker.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.joinKey -}}
{{- .Values.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "worker.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.joinKeySecretName -}}
{{- .Values.joinKeySecretName -}}
{{- else -}}
{{ include "worker.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "worker.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.masterKey -}}
{{- .Values.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "worker.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.masterKeySecretName -}}
{{- .Values.masterKeySecretName -}}
{{- else -}}
{{ include "worker.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "worker.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "worker.copyCustomCerts" -}}
echo "Copy custom certificates to /opt/jfrog/worker/var/data/router/keys/trusted";
mkdir -p /opt/jfrog/worker/var/data/router/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} /opt/jfrog/worker/var/data/router/keys/trusted; fi done;
if [ -f /opt/jfrog/worker/var/data/router/keys/trusted/tls.crt ]; then mv -v /opt/jfrog/worker/var/data/router/keys/trusted/tls.crt /opt/jfrog/worker/var/data/router/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "worker.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- end -}}
{{- if .Values.common.customInitContainers -}}
{{- .Values.common.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "worker.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "worker.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- end -}}
{{- if .Values.common.customVolumes -}}
{{- .Values.common.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts value
*/}}
{{- define "worker.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- end -}}
{{- if .Values.common.customVolumeMounts -}}
{{- .Values.common.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve Worker pod node selector value
*/}}
{{- define "worker.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.nodeSelector }}
{{ toYaml .Values.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "worker.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfrogUrl -}}
{{- .Values.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Extract jfrogUrl host
*/}}
{{- define "worker.jfrogUrlHost" -}}
{{- (urlParse (tpl (include "worker.jfrogUrl" .) .)).host -}}
{{- end -}}

{{/*
Calculate the systemYaml from structured and unstructured text input
*/}}
{{- define "worker.finalSystemYaml" -}}
{{ tpl (mergeOverwrite (include "worker.systemYaml" . | fromYaml) .Values.extraSystemYaml | toYaml) . }}
{{- end -}}

{{/*
Calculate the systemYaml from the unstructured text input
*/}}
{{- define "worker.systemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}

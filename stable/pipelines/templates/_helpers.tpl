{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pipelines.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pipelines.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
The services name
*/}}
{{- define "pipelines.services.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-services" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The api name
*/}}
{{- define "pipelines.api.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-api" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The www name
*/}}
{{- define "pipelines.www.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-www" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The msg name
*/}}
{{- define "pipelines.msg.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-msg" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The vault name
*/}}
{{- define "pipelines.vault.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-vault" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "pipelines.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "pipelines.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pipelines.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pipelines.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "pipelines.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Set grcp url
*/}}
{{- define "pipelines.grpc.url" -}}
{{- if (hasPrefix "https://" .Values.pipelines.jfrogUrl) }}
{{- printf "%s" (tpl .Values.pipelines.jfrogUrl . ) | replace "https://" "" }}
{{- else if (hasPrefix "http://" .Values.pipelines.jfrogUrl) }}
{{- printf "%s" (tpl .Values.pipelines.jfrogUrl . ) | replace "http://" "" }}
{{- else }}
{{- printf "%s" (tpl .Values.pipelines.jfrogUrl . ) }}
{{- end }}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "pipelines.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.pipelines.jfrogUrl -}}
{{- .Values.pipelines.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrlUI value
*/}}
{{- define "pipelines.jfrogUrlUI" -}}
{{- if .Values.global.jfrogUrlUI -}}
{{- .Values.global.jfrogUrlUI -}}
{{- else if .Values.pipelines.jfrogUrlUI -}}
{{- .Values.pipelines.jfrogUrlUI -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "pipelines.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.pipelines.joinKey -}}
{{- .Values.pipelines.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "pipelines.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.pipelines.masterKey -}}
{{- .Values.pipelines.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve imageRegistry value
*/}}
{{- define "pipelines.imageRegistry" -}}
{{- if .Values.global.imageRegistry -}}
{{- .Values.global.imageRegistry -}}
{{- else if .Values.imageRegistry -}}
{{- .Values.imageRegistry -}}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "pipelines.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if .Values.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "pipelines.vault.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.vault.customInitContainers -}}
{{- .Values.vault.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "pipelines.vault.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- else if .Values.vault.customVolumes -}}
{{- .Values.vault.customVolumes -}}
{{- end -}}
{{- end -}}


{{/*
Resolve customVolumeMounts value
*/}}
{{- define "pipelines.vault.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- else if .Values.vault.customVolumeMounts -}}
{{- .Values.vault.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "pipelines.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- else if .Values.pipelines.customSidecarContainers -}}
{{- .Values.pipelines.customSidecarContainers -}}
{{- end -}}
{{- end -}}

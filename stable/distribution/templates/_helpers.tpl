{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "distribution.name" -}}
{{- default .Chart.Name .Values.distribution.name .Values.distributionNameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The distributor name
*/}}
{{- define "distributor.name" -}}
{{- default .Chart.Name .Values.distributor.name .Values.distributorNameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified distribution name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "distribution.fullname" -}}
{{- if .Values.distribution.fullnameOverride -}}
{{- .Values.distribution.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.distribution.name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Create a default fully qualified distributor name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "distributor.fullname" -}}
{{- if .Values.distributor.fullnameOverride -}}
{{- .Values.distributor.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.distributor.name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "distribution.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "distribution.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "distribution.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "distribution.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "distribution.joinKey" -}}
{{- default .Values.distribution.joinKey .Values.global.joinKey -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "distribution.masterKey" -}}
{{- default .Values.distribution.masterKey .Values.global.masterKey -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "distribution.joinKeySecretName" -}}
{{- default (default (include "distribution.fullname" .) .Values.distribution.joinKeySecretName) .Values.global.joinKeySecretName -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "distribution.masterKeySecretName" -}}
{{- default (default (include "distribution.fullname" .) .Values.distribution.masterKeySecretName) .Values.global.masterKeySecretName -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "distribution.imagePullSecrets" -}}
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
{{- define "distribution.customInitContainers" -}}
{{- default .Values.distribution.customInitContainers .Values.global.customInitContainers -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "distribution.customVolumes" -}}
{{- default .Values.distribution.customVolumes .Values.global.customVolumes -}}
{{- end -}}

{{/*
Resolve customVolumeMounts value
*/}}
{{- define "distribution.customVolumeMounts" -}}
{{- default .Values.distribution.customVolumeMounts .Values.global.customVolumeMounts -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "distribution.customSidecarContainers" -}}
{{- default .Values.distribution.customSidecarContainers .Values.global.customSidecarContainers -}}
{{- end -}}

{{/*
Resolve consoleLog value
*/}}
{{- define "distribution.consoleLog" -}}
{{- default .Values.distribution.consoleLog .Values.global.consoleLog -}}
{{- end -}}

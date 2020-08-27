{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "xray.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-analysis name
*/}}
{{- define "xray-analysis.name" -}}
{{- default .Chart.Name .Values.analysis.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-indexer name
*/}}
{{- define "xray-indexer.name" -}}
{{- default .Chart.Name .Values.indexer.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-persist name
*/}}
{{- define "xray-persist.name" -}}
{{- default .Chart.Name .Values.persist.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-server name
*/}}
{{- define "xray-server.name" -}}
{{- default .Chart.Name .Values.server.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray.fullname" -}}
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
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray-analysis.fullname" -}}
{{- if .Values.analysis.fullnameOverride -}}
{{- .Values.analysis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.analysis.name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray-indexer.fullname" -}}
{{- if .Values.indexer.fullnameOverride -}}
{{- .Values.indexer.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.indexer.name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray-persist.fullname" -}}
{{- if .Values.persist.fullnameOverride -}}
{{- .Values.persist.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.persist.name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray-server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.server.name -}}
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
{{- define "xray.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "xray.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "xray.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create rabbitmq URL 
*/}}
{{- define "rabbitmq.url" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- $rabbitmqPort := .Values.rabbitmq.service.port -}}
{{- printf "%s://%s-%s:%g/" "amqp" .Release.Name "rabbitmq" $rabbitmqPort -}}
{{- else if index .Values "rabbitmq-ha" "enabled" -}}
{{- $rabbitmqHaPort := index .Values "rabbitmq-ha" "rabbitmqNodePort" -}}
{{- printf "%s://%s-%s:%g/" "amqp" .Release.Name "rabbitmq-ha" $rabbitmqHaPort -}}
{{- end -}}
{{- end -}}


{{/*
Create rabbitmq username 
*/}}
{{- define "rabbitmq.user" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- .Values.rabbitmq.auth.username -}}
{{- else if index .Values "rabbitmq-ha" "enabled" -}}
{{- index .Values "rabbitmq-ha" "rabbitmqUsername" -}}
{{- end -}} 
{{- end -}}


{{/*
Create rabbitmq password secret name
*/}}
{{- define "rabbitmq.passwordSecretName" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- .Values.rabbitmq.auth.existingPasswordSecret | default (printf "%s-%s" .Release.Name "rabbitmq") -}}
{{- else if index .Values "rabbitmq-ha" "enabled" -}}
{{- index .Values "rabbitmq-ha" "existingSecret" | default (printf "%s-%s" .Release.Name "rabbitmq-ha") -}}
{{- end -}} 
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "xray.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "xray.jfrogUrl" -}}
{{- default .Values.xray.joinKey .Values.global.jfrogUrl -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "xray.joinKey" -}}
{{- default .Values.xray.joinKey .Values.global.joinKey -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "xray.masterKey" -}}
{{- default .Values.xray.masterKey .Values.global.masterKey -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "xray.joinKeySecretName" -}}
{{- default (default (include "xray.fullname" .) .Values.xray.joinKeySecretName) .Values.global.joinKeySecretName -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "xray.masterKeySecretName" -}}
{{- default (default (include "xray.fullname" .) .Values.xray.masterKeySecretName) .Values.global.masterKeySecretName -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "xray.imagePullSecrets" -}}
{{- default .Values.imagePullSecrets .Values.global.imagePullSecrets -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "xray.customInitContainers" -}}
{{- default .Values.xray.customInitContainers .Values.global.customInitContainers -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "xray.customVolumes" -}}
{{- default .Values.xray.customVolumes .Values.global.customVolumes -}}
{{- end -}}


{{/*
Resolve customVolumeMounts value
*/}}
{{- define "xray.customVolumeMounts" -}}
{{- default .Values.xray.customVolumeMounts .Values.global.customVolumeMounts -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "xray.customSidecarContainers" -}}
{{- default .Values.xray.customSidecarContainers .Values.global.customSidecarContainers -}}
{{- end -}}

{{/*
Resolve consoleLog value
*/}}
{{- define "xray.consoleLog" -}}
{{- default .Values.xray.consoleLog .Values.global.consoleLog -}}
{{- end -}}


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
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.xray.jfrogUrl -}}
{{- .Values.xray.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "xray.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.xray.joinKey -}}
{{- .Values.xray.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "xray.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.xray.masterKey -}}
{{- .Values.xray.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "xray.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.xray.joinKeySecretName -}}
{{- .Values.xray.joinKeySecretName -}}
{{- else -}}
{{ include "xray.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "xray.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.xray.masterKeySecretName -}}
{{- .Values.xray.masterKeySecretName -}}
{{- else -}}
{{ include "xray.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "xray.imagePullSecrets" -}}
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
Resolve customInitContainersBegin value
*/}}
{{- define "xray.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.common.customInitContainersBegin -}}
{{- .Values.common.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "xray.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.common.customInitContainers -}}
{{- .Values.common.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "xray.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- else if .Values.common.customVolumes -}}
{{- .Values.common.customVolumes -}}
{{- end -}}
{{- end -}}


{{/*
Resolve customVolumeMounts value
*/}}
{{- define "xray.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- else if .Values.common.customVolumeMounts -}}
{{- .Values.common.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "xray.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- else if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper xray chart image names
*/}}
{{- define "xray.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default (default $dot.Chart.AppVersion $dot.Values.common.xrayVersion (index $dot.Values $indexReference "image" "tag"))  | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if $dot.Values.global }}
    {{- if $dot.Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" $dot.Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper xray router image name
*/}}
{{- define "router.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := index $dot.Values $indexReference "image" "tag" | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if $dot.Values.global }}
    {{- if $dot.Values.global.imageRegistry }}
        {{- printf "%s/%s:%s" $dot.Values.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

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

{{- define "pipelines.sync.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-sync" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pipelines.trigger.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-trigger" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pipelines.steptrigger.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-steptrigger" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pipelines.extensionsync.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-extensionsync" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pipelines.cron.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-cron" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pipelines.templatesync.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-templatesync" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pipelines.hookhandler.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-hookhandler" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The api name
*/}}
{{- define "pipelines.api.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-api" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The internal api name
*/}}
{{- define "pipelines.internalapi.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-internalapi" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The www name
*/}}
{{- define "pipelines.www.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-www" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The frontend name
*/}}
{{- define "pipelines.frontend.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-frontend" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The nodepoolservice name
*/}}
{{- define "pipelines.nodepoolservice.name" -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-nodepoolservice" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
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
Common template labels
*/}}
{{- define "pipelines.common.labels" -}}
app: {{ template "pipelines.name" . }}
chart: {{ template "pipelines.chart" . }}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pipelines.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for sync
*/}}
{{- define "pipelines.sync.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.sync.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for internalapi
*/}}
{{- define "pipelines.internalapi.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.internalapi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for www
*/}}
{{- define "pipelines.www.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.www.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for runtrigger
*/}}
{{- define "pipelines.trigger.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.trigger.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for steptrigger
*/}}
{{- define "pipelines.steptrigger.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.steptrigger.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for extensionsync
*/}}
{{- define "pipelines.extensionsync.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.extensionsync.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for cron
*/}}
{{- define "pipelines.cron.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.cron.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for reqsealer
*/}}
{{- define "pipelines.reqsealer.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.reqsealer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for templatesync
*/}}
{{- define "pipelines.templatesync.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.templatesync.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common labels for hookhandler
*/}}
{{- define "pipelines.hookhandler.labels" -}}
helm.sh/chart: {{ include "pipelines.chart" . }}
{{ include "pipelines.hookhandler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "pipelines.app.version" . | quote }}
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
Selector labels for sync pod
*/}}
{{- define "pipelines.sync.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.sync.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for internal api pod
*/}}
{{- define "pipelines.internalapi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.internalapi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for www pod
*/}}
{{- define "pipelines.www.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.www.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for trigger pod
*/}}
{{- define "pipelines.trigger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.trigger.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for steptrigger pod
*/}}
{{- define "pipelines.steptrigger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.steptrigger.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for cron pod
*/}}
{{- define "pipelines.cron.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.cron.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for hookhandler pod
*/}}
{{- define "pipelines.hookhandler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipelines.hookhandler.name" . }}
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
Resolve joinKeySecretName value
*/}}
{{- define "pipelines.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.pipelines.joinKeySecretName -}}
{{- .Values.pipelines.joinKeySecretName -}}
{{- else -}}
{{ include "pipelines.fullname" . }}
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
Resolve masterKeySecretName value
*/}}
{{- define "pipelines.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.pipelines.masterKeySecretName -}}
{{- .Values.pipelines.masterKeySecretName -}}
{{- else -}}
{{ include "pipelines.fullname" . }}
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
Resolve customInitContainersBegin value
*/}}
{{- define "pipelines.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.customInitContainersBegin -}}
{{- .Values.pipelines.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "pipelines.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.customInitContainers -}}
{{- .Values.pipelines.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value for cron
*/}}
{{- define "pipelines.cron.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.cron.customInitContainersBegin -}}
{{- .Values.pipelines.cron.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value for cron
*/}}
{{- define "pipelines.cron.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.cron.customInitContainers -}}
{{- .Values.pipelines.cron.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value for hookhandler
*/}}
{{- define "pipelines.hookhandler.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.hookHandler.customInitContainersBegin -}}
{{- .Values.pipelines.hookHandler.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value for hookhandler
*/}}
{{- define "pipelines.hookhandler.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.hookHandler.customInitContainers -}}
{{- .Values.pipelines.hookHandler.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value for internalapi
*/}}
{{- define "pipelines.internalapi.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.internalapi.customInitContainersBegin -}}
{{- .Values.pipelines.internalapi.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value for internalapi
*/}}
{{- define "pipelines.internalapi.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.internalapi.customInitContainers -}}
{{- .Values.pipelines.internalapi.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value for steptrigger
*/}}
{{- define "pipelines.steptrigger.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.stepTrigger.customInitContainersBegin -}}
{{- .Values.pipelines.stepTrigger.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value for steptrigger
*/}}
{{- define "pipelines.steptrigger.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.stepTrigger.customInitContainers -}}
{{- .Values.pipelines.stepTrigger.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value for sync
*/}}
{{- define "pipelines.sync.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.pipelineSync.customInitContainersBegin -}}
{{- .Values.pipelines.pipelineSync.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value for sync
*/}}
{{- define "pipelines.sync.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.pipelineSync.customInitContainers -}}
{{- .Values.pipelines.pipelineSync.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value for trigger
*/}}
{{- define "pipelines.trigger.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- else if .Values.pipelines.runTrigger.customInitContainersBegin -}}
{{- .Values.pipelines.runTrigger.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value for trigger
*/}}
{{- define "pipelines.trigger.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- else if .Values.pipelines.runTrigger.customInitContainers -}}
{{- .Values.pipelines.runTrigger.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "pipelines.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- else if .Values.pipelines.customVolumes -}}
{{- .Values.pipelines.customVolumes -}}
{{- end -}}
{{- end -}}


{{/*
Resolve customVolumeMounts value
*/}}
{{- define "pipelines.vault.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- end -}}
{{- if .Values.vault.customVolumeMounts -}}
{{- .Values.vault.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "pipelines.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.customSidecarContainers -}}
{{- .Values.pipelines.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value for cron
*/}}
{{- define "pipelines.cron.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.cron.customSidecarContainers -}}
{{- .Values.pipelines.cron.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value for hookhandler
*/}}
{{- define "pipelines.hookhandler.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.hookHandler.customSidecarContainers -}}
{{- .Values.pipelines.hookHandler.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value for internalapi
*/}}
{{- define "pipelines.internalapi.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.internalapi.customSidecarContainers -}}
{{- .Values.pipelines.internalapi.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value for steptrigger
*/}}
{{- define "pipelines.steptrigger.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.stepTrigger.customSidecarContainers -}}
{{- .Values.pipelines.stepTrigger.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value for sync
*/}}
{{- define "pipelines.sync.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.pipelineSync.customSidecarContainers -}}
{{- .Values.pipelines.pipelineSync.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value for trigger
*/}}
{{- define "pipelines.trigger.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pipelines.runTrigger.customSidecarContainers -}}
{{- .Values.pipelines.runTrigger.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper pipelines chart image names
*/}}
{{- define "pipelines.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference1 := index . 1 }}
{{- $indexReference2 := index . 2 }}
{{- $registryName := default $dot.Values.imageRegistry (index $dot.Values $indexReference1 $indexReference2 "image" "registry") -}}
{{- $repositoryName := index $dot.Values $indexReference1 $indexReference2 "image" "repository" -}}
{{- $tag := default (default $dot.Chart.AppVersion $dot.Values.pipelines.version) (index $dot.Values $indexReference1 $indexReference2 "image" "tag")  | toString -}}
{{- if $dot.Values.global }}
    {{- if $dot.Values.global.versions.pipelines }}
    {{- $tag = $dot.Values.global.versions.pipelines | toString -}}
    {{- end -}}
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
Common code to add metrics
*/}}
{{- define "pipelines.addMetrics" -}}
export new_script_path=/tmp/add_metrics.sh;
cp -fv /pipelines-utility-scripts/add_metrics.sh "${new_script_path}"; chmod +x "${new_script_path}";
bash "${new_script_path}" "${PIP_CONTAINER_START_TIME}" "{{ .Values.pipelines.logPath }}/${PIP_METRIC_FILE_PREFIX}-metrics.log" "kubernetes-init" || true;
{{- end -}}

{{/*
Common code to change ownership of metrics file
*/}}
{{- define "pipelines.changeOwnershipMetrics" -}}
chown 1066:1066 {{ .Values.pipelines.logPath }}/*-metrics.log || true;
{{- end -}}

{{/*
Return the proper vault image name
*/}}
{{- define "vault.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := default $dot.Values.imageRegistry (index $dot.Values $indexReference "image" "registry") -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
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
Return the proper pipelines app version
*/}}
{{- define "pipelines.app.version" -}}
{{- $image := split ":" ((include "pipelines.getImageInfoByValue" (list . "pipelines" "pipelinesInit" )) | toString) -}}
{{- $tag := $image._1 -}}
{{- printf "%s" $tag -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "pipelines.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.pipelines.mountPath }}/security/keys/trusted";
mkdir -p {{ .Values.pipelines.mountPath }}/security/keys/trusted;
if [ -f /tmp/certs/tls.crt ]; then cp -v /tmp/certs/tls.crt {{ .Values.pipelines.mountPath }}/security/keys/trusted/pipelines_custom_certs.crt; fi;
chown -R 1066:1066 {{ .Values.pipelines.mountPath }}
{{- end -}}

{{/*
Resolve pipelines requiredServiceTypes value
*/}}
{{- define "pipelines.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfpip,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve Pipelines pod node selector value
*/}}
{{- define "pipelines.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.pipelines.nodeSelector }}
{{ toYaml .Values.pipelines.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedCustomSecretVolumeName value
*/}}
{{- define "pipelines.unifiedCustomSecretVolumeName" -}}
{{- printf "%s-%s" (include "pipelines.name" .) ("unified-secret-volume") | trunc 63 -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "pipelines.checkDuplicateUnifiedCustomVolume" -}}
{{- if or .Values.global.customVolumes .Values.pipelines.customVolumes -}}
{{- $val := (tpl (include "pipelines.customVolumes" .) .) | toJson -}}
{{- contains (include "pipelines.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

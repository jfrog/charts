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
find /tmp/certs -type f -not -name "*.key" -exec cp -v {} {{ .Values.pipelines.mountPath }}/security/keys/trusted \;;
find {{ .Values.pipelines.mountPath }}/security/keys/trusted/ -type f -name "tls.crt" -exec mv -v {} {{ .Values.pipelines.mountPath }}/security/keys/trusted/ca.crt \;;
chown -R 1066:1066 {{ .Values.pipelines.mountPath }}
{{- end -}}

{{/*
pipelines liveness probe
*/}}
{{- define "pipelines.livenessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/" -}}
{{- end -}}
{{- end -}}

{{/*
pipelines readiness probe
*/}}
{{- define "pipelines.readinessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/" -}}
{{- end -}}
{{- end -}}

{{/*
router liveness probe
*/}}
{{- define "pipelines.router.livenessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/router/api/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
router readiness probe
*/}}
{{- define "pipelines.router.readinessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/router/api/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve pipelines requiredServiceTypes value
*/}}
{{- define "pipelines.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfpip" -}}
{{- $requiredTypes -}}
{{- end -}}

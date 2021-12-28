{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "insight.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "insight.fullname" -}}
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
Create a list of elasticsearch master eligible nodes.
This will create one entry per replica.
*/}}
{{- define "elasticsearch.endpoints" -}}
{{- $replicas := 1 }}
{{- $releaseName := printf "%s" (include "insight.fullname" .) }}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $releaseName }}-{{ $i }},
  {{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "insight-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "insight.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "insight-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "insight.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "insight-server.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.insightServer.jfrogUrl -}}
{{- .Values.insightServer.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "insight-server.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.insightServer.joinKey -}}
{{- .Values.insightServer.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "insight-server.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.insightServer.masterKey -}}
{{- .Values.insightServer.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "insight-server.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.insightServer.joinKeySecretName -}}
{{- .Values.insightServer.joinKeySecretName -}}
{{- else -}}
{{ include "insight.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "insight-server.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.insightServer.masterKeySecretName -}}
{{- .Values.insightServer.masterKeySecretName -}}
{{- else -}}
{{ include "insight.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "insight-server.imagePullSecrets" -}}
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
{{- define "insight-server.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- end -}}
{{- if .Values.common.customInitContainersBegin -}}
{{- .Values.common.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "insight-server.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- end -}}
{{- if .Values.common.customInitContainers -}}
{{- .Values.common.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "insight-server.customVolumes" -}}
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
{{- define "insight-server.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- end -}}
{{- if .Values.common.customVolumeMounts -}}
{{- .Values.common.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "insight-server.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper insight-server chart image names
*/}}
{{- define "insight-server.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.insight (or (eq $indexReference "insightScheduler") (eq $indexReference "insightServer") ) }}
    {{- $tag = $dot.Values.global.versions.insight | toString -}}
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
Resolve elastic search url
*/}}
{{- define "elasticsearch.url" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "https://localhost:%d" (int .Values.router.internalPort) -}}
{{- else -}}
{{- printf "http://localhost:%d" (int .Values.router.internalPort) -}}
{{- end -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "insight-server.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.insightServer.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.insightServer.persistence.mountPath }}/etc/security/keys/trusted;
find /tmp/certs -type f -not -name "*.key" -exec cp -v {} {{ .Values.insightServer.persistence.mountPath }}/etc/security/keys/trusted \;;
find {{ .Values.insightServer.persistence.mountPath }}/etc/security/keys/trusted/ -type f -name "tls.crt" -exec mv -v {} {{ .Values.insightServer.persistence.mountPath }}/etc/security/keys/trusted/ca.crt \;;
{{- end -}}

{{/*
insight liveness probe
*/}}
{{- define "insight.livenessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/api/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/api/v1/system/ping" -}}
{{- end -}}
{{- end -}}

{{/*
insight readiness probe
*/}}
{{- define "insight.readinessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/api/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/api/v1/system/ping" -}}
{{- end -}}
{{- end -}}

{{/*
router liveness probe
*/}}
{{- define "insight.router.livenessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/router/api/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
router readiness probe
*/}}
{{- define "insight.router.readinessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/router/api/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve requiredServiceTypes value
*/}}
{{- define "insight.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfisc,jfisv" -}}
{{- if .Values.elasticsearch.enabled }}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfesc" -}}
{{- end -}}
{{- $requiredTypes -}}
{{- end -}}

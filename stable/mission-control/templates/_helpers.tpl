{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mission-control.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mission-control.fullname" -}}
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
{{- $releaseName := printf "%s" (include "mission-control.fullname" .) }}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $releaseName }}-{{ $i }},
  {{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mission-control.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "mission-control.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mission-control.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "mission-control.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "mission-control.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.missionControl.jfrogUrl -}}
{{- .Values.missionControl.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "mission-control.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.missionControl.joinKey -}}
{{- .Values.missionControl.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "mission-control.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.missionControl.masterKey -}}
{{- .Values.missionControl.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "mission-control.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.missionControl.joinKeySecretName -}}
{{- .Values.missionControl.joinKeySecretName -}}
{{- else -}}
{{ include "mission-control.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "mission-control.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.missionControl.masterKeySecretName -}}
{{- .Values.missionControl.masterKeySecretName -}}
{{- else -}}
{{ include "mission-control.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "mission-control.imagePullSecrets" -}}
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
{{- define "mission-control.customInitContainersBegin" -}}
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
{{- define "mission-control.customInitContainers" -}}
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
{{- define "mission-control.customVolumes" -}}
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
{{- define "mission-control.customVolumeMounts" -}}
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
{{- define "mission-control.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper mission-control chart image names
*/}}
{{- define "mission-control.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.missionControl (or (eq $indexReference "insightScheduler") (eq $indexReference "missionControl") (eq $indexReference "insightServer") ) }}
    {{- $tag = $dot.Values.global.versions.missionControl | toString -}}
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
{{- define "mission-control.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.missionControl.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.missionControl.persistence.mountPath }}/etc/security/keys/trusted;
find /tmp/certs -type f -not -name "*.key" -exec cp -v {} {{ .Values.missionControl.persistence.mountPath }}/etc/security/keys/trusted \;;
find {{ .Values.missionControl.persistence.mountPath }}/etc/security/keys/trusted/ -type f -name "tls.crt" -exec mv -v {} {{ .Values.missionControl.persistence.mountPath }}/etc/security/keys/trusted/ca.crt \;;
{{- end -}}

{{/*
mission-control liveness probe
*/}}
{{- define "mission-control.livenessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/api/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/api/v1/system/ping" -}}
{{- end -}}
{{- end -}}

{{/*
mission-control readiness probe
*/}}
{{- define "mission-control.readinessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/api/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/api/v1/system/ping" -}}
{{- end -}}
{{- end -}}

{{/*
router liveness probe
*/}}
{{- define "mission-control.router.livenessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/router/api/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
router readiness probe
*/}}
{{- define "mission-control.router.readinessProbe" -}}
{{- if .Values.newProbes -}}
{{- printf "%s" "/router/api/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}
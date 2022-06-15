{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "pdn-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified pdnserver name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pdn-server.fullname" -}}
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
Create the name of the service account to use
*/}}
{{- define "pdn-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "pdn-server.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pdn-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pdn-server.labels" -}}
helm.sh/chart: {{ include "pdn-server.chart" . }}
{{ include "pdn-server.selectorLabels" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "pdn-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pdn-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "pdn-server.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "pdn-server.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.pdnServer.jfrogUrl -}}
{{- .Values.pdnServer.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "pdn-server.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.pdnServer.joinKey -}}
{{- .Values.pdnServer.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "pdn-server.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.pdnServer.masterKey -}}
{{- .Values.pdnServer.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "pdn-server.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.pdnServer.joinKeySecretName -}}
{{- .Values.pdnServer.joinKeySecretName -}}
{{- else -}}
{{ include "pdn-server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "pdn-server.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.pdnServer.masterKeySecretName -}}
{{- .Values.pdnServer.masterKeySecretName -}}
{{- else -}}
{{ include "pdn-server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "pdn-server.imagePullSecrets" -}}
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
{{- define "pdn-server.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- end -}}
{{- if .Values.pdnServer.customInitContainersBegin -}}
{{- .Values.pdnServer.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "pdn-server.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- end -}}
{{- if .Values.pdnServer.customInitContainers -}}
{{- .Values.pdnServer.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "pdn-server.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- end -}}
{{- if .Values.pdnServer.customVolumes -}}
{{- .Values.pdnServer.customVolumes -}}
{{- end -}}
{{- end -}}


{{/*
Resolve customVolumeMounts value
*/}}
{{- define "pdn-server.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- end -}}
{{- if .Values.pdnServer.customVolumeMounts -}}
{{- .Values.pdnServer.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "pdn-server.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.pdnServer.customSidecarContainers -}}
{{- .Values.pdnServer.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper pdnserver chart image names
*/}}
{{- define "pdn-server.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.pdnServer (eq $indexReference "pdnServer") }}
    {{- $tag = $dot.Values.global.versions.pdnServer | toString -}}
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
Custom certificate copy command
*/}}
{{- define "pdn-server.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.pdnServer.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.pdnServer.persistence.mountPath }}/etc/security/keys/trusted;
find /tmp/certs -type f -not -name "*.key" -exec cp -v {} {{ .Values.pdnServer.persistence.mountPath }}/etc/security/keys/trusted \;;
find {{ .Values.pdnServer.persistence.mountPath }}/etc/security/keys/trusted/ -type f -name "tls.crt" -exec mv -v {} {{ .Values.pdnServer.persistence.mountPath }}/etc/security/keys/trusted/ca.crt \;;
{{- end -}}

{{/*
pdnserver liveness probe
*/}}
{{- define "pdn-server.livenessProbe" -}}
{{- printf "%s" "/api/v1/system/liveness" -}}
{{- end -}}

{{/*
pdnserver readiness probe
*/}}
{{- define "pdn-server.readinessProbe" -}}
{{- printf "%s" "/api/v1/system/readiness" -}}
{{- end -}}

{{/*
Resolve pdnserver requiredServiceTypes value
*/}}
{{- define "pdn-server.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jftrk,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve pdnserver pod node selector value
*/}}
{{- define "pdn-server.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.pdnServer.nodeSelector }}
{{ toYaml .Values.pdnServer.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}


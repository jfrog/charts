{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "distribution.name" -}}
{{- default .Chart.Name .Values.distribution.name .Values.distributionNameOverride | trunc 63 | trimSuffix "-" -}}
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
Resolve jfrogUrl value
*/}}
{{- define "distribution.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.distribution.jfrogUrl -}}
{{- .Values.distribution.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "distribution.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.distribution.joinKey -}}
{{- .Values.distribution.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "distribution.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.distribution.masterKey -}}
{{- .Values.distribution.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "distribution.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.distribution.joinKeySecretName -}}
{{- .Values.distribution.joinKeySecretName -}}
{{- else -}}
{{ include "distribution.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "distribution.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.distribution.masterKeySecretName -}}
{{- .Values.distribution.masterKeySecretName -}}
{{- else -}}
{{ include "distribution.fullname" . }}
{{- end -}}
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
Resolve customInitContainersBegin value
*/}}
{{- define "distribution.customInitContainersBegin" -}}
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
{{- define "distribution.customInitContainers" -}}
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
{{- define "distribution.customVolumes" -}}
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
{{- define "distribution.customVolumeMounts" -}}
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
{{- define "distribution.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper distribution app version
*/}}
{{- define "distribution.app.version" -}}
{{- $tag := (splitList ":" ((include "distribution.getImageInfoByValue" (list . "distribution" )))) | last | toString -}}
{{- printf "%s" $tag -}}
{{- end -}}

{{/*
Return the proper distribution chart image names
*/}}
{{- define "distribution.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.initContainers (eq $indexReference "initContainers") }}
    {{- $tag = $dot.Values.global.versions.initContainers | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.distribution (eq $indexReference "distribution") }}
    {{- $tag = $dot.Values.global.versions.distribution | toString -}}
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
{{- define "distribution.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.distribution.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.distribution.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.distribution.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.distribution.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.distribution.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.distribution.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
Resolve distribution requiredServiceTypes value
*/}}
{{- define "distribution.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfds,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve Distribution pod node selector value
*/}}
{{- define "distribution.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.distribution.nodeSelector }}
{{ toYaml .Values.distribution.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedCustomSecretVolumeName value
*/}}
{{- define "distribution.unifiedCustomSecretVolumeName" -}}
{{- printf "%s-%s" (include "distribution.name" .) ("unified-secret-volume") | trunc 63 -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.
*/}}
{{- define "distribution.checkDuplicateUnifiedCustomVolume" -}}
{{- if or .Values.global.customVolumes .Values.distribution.customVolumes -}}
{{- $val := (tpl (include "distribution.customVolumes" .) .) | toJson -}}
{{- contains (include "distribution.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
Calculate the systemYaml from structured and unstructured text input
*/}}
{{- define "distribution.finalSystemYaml" -}}
{{ tpl (mergeOverwrite (include "distribution.systemYaml" . | fromYaml) .Values.distribution.extraSystemYaml | toYaml) . }}
{{- end -}}

{{/*
Calculate the systemYaml from the unstructured text input
*/}}
{{- define "distribution.systemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}

{{/*
Resolve unified secret prepend release name
*/}}
{{- define "distribution.unifiedSecretPrependReleaseName" -}}
{{- if .Values.distribution.unifiedSecretPrependReleaseName }}
{{- printf "%s" (include "distribution.fullname" .) -}}
{{- else }}
{{- printf "%s" (include "distribution.name" .) -}}
{{- end }}
{{- end }}

{{/*
Resolve autoscalling metrics value
*/}}
{{- define "distribution.metrics" -}}
{{- if .Values.autoscaling.metrics -}}
{{- .Values.autoscaling.metrics -}}
{{- end -}}
{{- end -}}


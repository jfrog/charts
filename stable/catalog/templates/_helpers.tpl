{{/*
Expand the name of the chart.
*/}}
{{- define "catalog.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "catalog.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Return the proper catalog image name
*/}}
{{- define "catalog.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "appVer" .Chart.AppVersion) }}
{{- end -}}

{{/*
Return the proper router image name
*/}}
{{- define "router.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.router.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "catalog.initContainers.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initContainers.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "catalog.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.initContainers.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return podAnnotations
*/}}
{{- define "catalog.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) }}
{{- end }}
{{- if and .Values.metrics.enabled .Values.metrics.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.metrics.podAnnotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "catalog.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "catalog.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "catalog.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.joinKey -}}
{{- .Values.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "catalog.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.masterKey -}}
{{- .Values.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "catalog.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.joinKeySecretName -}}
{{- .Values.joinKeySecretName -}}
{{- else -}}
{{ include "catalog.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "catalog.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.masterKeySecretName -}}
{{- .Values.masterKeySecretName -}}
{{- else -}}
{{ include "catalog.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "catalog.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve catalog requiredServiceTypes value
*/}}
{{- define "catalog.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfevt" -}}
{{- if .Values.observability.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfob" -}}
{{- end -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "catalog.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfrogUrl -}}
{{- .Values.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Extract jfrogUrl host
*/}}
{{- define "catalog.jfrogUrlHost" -}}
{{- (urlParse (tpl (include "catalog.jfrogUrl" .) .)).host -}}
{{- end -}}

{{/*
Calculate the systemYaml from structured and unstructured text input
*/}}
{{- define "catalog.finalSystemYaml" -}}
{{- if .Values.extraSystemYaml }}
{{ tpl (mergeOverwrite (include "catalog.systemYaml" . | fromYaml) .Values.extraSystemYaml | toYaml) . }}
{{- else }}
{{ include "catalog.systemYaml" . }}
{{- end }}
{{- end -}}

{{/*
Calculate the systemYaml from the unstructured text input
*/}}
{{- define "catalog.systemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}

{{/*
Resolve customInitContainersBegin value
*/}}
{{- define "catalog.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- end -}}
{{- if .Values.customInitContainersBegin -}}
{{- .Values.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "catalog.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- end -}}
{{- if .Values.customVolumes -}}
{{- .Values.customVolumes -}}
{{- end -}}
{{- end -}}


{{/*
Return the proper catalog chart image names
*/}}
{{- define "catalog.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values "image" "registry" -}}
{{- $repositoryName := index $dot.Values "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values "image" "tag") | toString -}}
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
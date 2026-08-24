{{/*
Expand the name of the chart.
*/}}
{{- define "bridge.name" -}}
{{- $name := printf "%s-%s" .Chart.Name .Values.mode -}}
{{- default $name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bridge.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := printf "%s-%s" .Chart.Name .Values.mode -}}
{{- $name = default $name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return the proper bridge image name
*/}}
{{- define "bridge.image" -}}
{{- $imageRoot := .Values.image | deepCopy }}
{{- if .Values.global.digests.bridge }}
{{- $_ := set $imageRoot "digest" .Values.global.digests.bridge }}
{{- end -}}
{{- trim (include "common.images.global.image" (dict "imageRoot" $imageRoot "global" .Values.global "globalVersion" .Values.global.versions.bridge "appVer" .Chart.AppVersion)) -}}
{{- end -}}

{{/*
Return the proper router image name
*/}}
{{- define "router.image" -}}
{{- $imageRoot := .Values.router.image | deepCopy }}
{{- if .Values.global.digests.router }}
{{- $_ := set $imageRoot "digest" .Values.global.digests.router }}
{{- end -}}
{{- trim (include "common.images.global.image" (dict "imageRoot" $imageRoot "global" .Values.global "globalVersion" .Values.global.versions.router)) -}}
{{- end -}}

{{/*
Return the proper initContainers image name
*/}}
{{- define "initContainers.image" -}}
{{- $imageRoot := .Values.initContainers.image | deepCopy }}
{{- if .Values.global.digests.initContainers }}
{{- $_ := set $imageRoot "digest" .Values.global.digests.initContainers }}
{{- end -}}
{{- trim (include "common.images.global.image" (dict "imageRoot" $imageRoot "global" .Values.global "globalVersion" .Values.global.versions.initContainers)) -}}
{{- end -}}

{{/*
Return the proper observability image name
*/}}
{{- define "observability.image" -}}
{{- $imageRoot := .Values.observability.image | deepCopy }}
{{- if .Values.global.digests.observability }}
{{- $_ := set $imageRoot "digest" .Values.global.digests.observability }}
{{- end -}}
{{- trim (include "common.images.global.image" (dict "imageRoot" $imageRoot "global" .Values.global "globalVersion" .Values.global.versions.observability)) -}}
{{- end -}}

{{/*
Return the proper filebeat image name
*/}}
{{- define "filebeat.image" -}}
{{- $imageRoot := .Values.filebeat.image | deepCopy }}
{{- if .Values.global.digests.filebeat }}
{{- $_ := set $imageRoot "digest" .Values.global.digests.filebeat }}
{{- end -}}
{{- trim (include "common.images.global.image" (dict "imageRoot" $imageRoot "global" .Values.global "globalVersion" .Values.global.versions.filebeat)) -}}
{{- end -}}

{{/*
    Return the proper Docker Image Registry Secret Names
*/}}
{{- define "bridge.imagePullSecrets" -}}
{{- if .Values.filebeat.enabled -}}
{{ include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.router.image .Values.initContainers.image .Values.observability.image .Values.filebeat.image) "context" $) }}
{{- else -}}
{{ include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.router.image .Values.initContainers.image .Values.observability.image) "context" $) }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bridge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bridge.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bridge.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve joinKey value
*/}}
{{- define "bridge.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.joinKey -}}
{{- .Values.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "bridge.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.joinKeySecretName -}}
{{- .Values.joinKeySecretName -}}
{{- else -}}
{{ include "bridge.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "bridge.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.masterKey -}}
{{- .Values.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "bridge.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.masterKeySecretName -}}
{{- .Values.masterKeySecretName -}}
{{- else -}}
{{ include "bridge.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve tunnelClientTokenSecretName value
*/}}
{{- define "bridge.tunnelClientTokenSecretName" -}}
{{- if .Values.tunnelClientTokenSecretName -}}
{{- .Values.tunnelClientTokenSecretName -}}
{{- else -}}
{{ include "bridge.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "bridge.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "bridge.copyCustomCerts" -}}
{{- if or .Values.customCertificates.enabled .Values.global.customCertificates.enabled -}}
echo "Copy custom certificates to /var/opt/jfrog/bridge/etc/security/keys/trusted";
mkdir -p /var/opt/jfrog/bridge/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} /var/opt/jfrog/bridge/etc/security/keys/trusted; fi done;
if [ -f /var/opt/jfrog/bridge/etc/security/keys/trusted/tls.crt ]; then mv -v /var/opt/jfrog/bridge/etc/security/keys/trusted/tls.crt /var/opt/jfrog/bridge/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}
{{- if .Values.tunnelClientCertificateSecretName -}}
echo "Copy tunnel client certificate to /var/opt/jfrog/bridge/data/bridge/tls_cert.crt";
mkdir -p /var/opt/jfrog/bridge/data/bridge;
cp /tmp/client-cert/tls_cert.crt /var/opt/jfrog/bridge/data/bridge/tls_cert.crt;
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "bridge.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- end -}}
{{- if .Values.common.customInitContainers -}}
{{- .Values.common.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "bridge.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve extraVolumes value
*/}}
{{- define "bridge.extraVolumes" -}}
{{- if .Values.global.extraVolumes -}}
{{- .Values.global.extraVolumes -}}
{{- end -}}
{{- if .Values.common.extraVolumes -}}
{{- .Values.common.extraVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve extraVolumeMounts value
*/}}
{{- define "bridge.extraVolumeMounts" -}}
{{- if .Values.global.extraVolumeMounts -}}
{{- .Values.global.extraVolumeMounts -}}
{{- end -}}
{{- if .Values.common.extraVolumeMounts -}}
{{- .Values.common.extraVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve Bridge pod node selector value
*/}}
{{- define "bridge.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.nodeSelector }}
{{ toYaml .Values.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "bridge.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfrogUrl -}}
{{- .Values.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Extract jfrogUrl host
*/}}
{{- define "bridge.jfrogUrlHost" -}}
{{- (urlParse (tpl (include "bridge.jfrogUrl" .) .)).host -}}
{{- end -}}

{{/*
Calculate the systemYaml from structured and unstructured text input
*/}}
{{- define "bridge.finalSystemYaml" -}}
{{ tpl (mergeOverwrite (include "bridge.systemYaml" . | fromYaml) .Values.extraSystemYaml | toYaml) . }}
{{- end -}}

{{/*
Calculate the systemYaml from the unstructured text input
*/}}
{{- define "bridge.systemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}

{{/*
Resolve bridge requiredServiceTypes value based on running mode
*/}}
{{- define "bridge.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfbrc" -}}
{{- if eq .Values.mode "server" -}}
{{- $requiredTypes = "jfbrs" -}}
{{- end -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve bridge service path based on running mode
*/}}
{{- define "bridge.servicePath" -}}
{{- $path := "bridge-client"}}
{{- if eq .Values.mode "server" -}}
{{- $path = "bridge-server" -}}
{{- end -}}
{{- $path -}}
{{- end -}}

{{/*
Render the bridge client bridges
*/}}
{{- define "bridge.clientBridges" -}}
{{- if .Values.tunnel.client.bridges }}
{{ toYaml .Values.tunnel.client.bridges }}
{{- end -}}
{{- end -}}
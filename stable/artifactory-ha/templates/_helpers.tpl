{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "artifactory-ha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The primary node name
*/}}
{{- define "artifactory-ha.primary.name" -}}
{{- if .Values.nameOverride -}}
{{- printf "%s-primary" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-primary" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
The member node name
*/}}
{{- define "artifactory-ha.node.name" -}}
{{- if .Values.nameOverride -}}
{{- printf "%s-member" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Release.Name | trunc 29 -}}
{{- printf "%s-%s-member" $name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name nginx service.
*/}}
{{- define "artifactory-ha.nginx.name" -}}
{{- default .Values.nginx.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "artifactory-ha.fullname" -}}
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
{{- define "artifactory-ha.nginx.fullname" -}}
{{- if .Values.nginx.fullnameOverride -}}
{{- .Values.nginx.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nginx.name -}}
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
{{- define "artifactory-ha.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "artifactory-ha.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "artifactory-ha.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate SSL certificates
*/}}
{{- define "artifactory-ha.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "artifactory-ha.fullname" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "artifactory-ha.fullname" .) .Release.Namespace ) -}}
{{- $ca := genCA "artifactory-ca" 365 -}}
{{- $cert := genSignedCert ( include "artifactory-ha.fullname" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Scheme (http/https) based on Access or Router TLS enabled/disabled
*/}}
{{- define "artifactory-ha.scheme" -}}
{{- if or .Values.access.accessConfig.security.tls .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "artifactory-ha.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.artifactory.joinKey -}}
{{- .Values.artifactory.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfConnectToken value
*/}}
{{- define "artifactory-ha.jfConnectToken" -}}
{{- .Values.artifactory.jfConnectToken -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "artifactory-ha.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.artifactory.masterKey -}}
{{- .Values.artifactory.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "artifactory-ha.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.artifactory.joinKeySecretName -}}
{{- .Values.artifactory.joinKeySecretName -}}
{{- else -}}
{{ include "artifactory-ha.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve jfConnectTokenSecretName value
*/}}
{{- define "artifactory-ha.jfConnectTokenSecretName" -}}
{{- if .Values.artifactory.jfConnectTokenSecretName -}}
{{- .Values.artifactory.jfConnectTokenSecretName -}}
{{- else -}}
{{ include "artifactory-ha.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "artifactory-ha.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.artifactory.masterKeySecretName -}}
{{- .Values.artifactory.masterKeySecretName -}}
{{- else -}}
{{ include "artifactory-ha.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "artifactory-ha.imagePullSecrets" -}}
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
{{- define "artifactory-ha.customInitContainersBegin" -}}
{{- if .Values.global.customInitContainersBegin -}}
{{- .Values.global.customInitContainersBegin -}}
{{- end -}}
{{- if .Values.artifactory.customInitContainersBegin -}}
{{- .Values.artifactory.customInitContainersBegin -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "artifactory-ha.customInitContainers" -}}
{{- if .Values.global.customInitContainers -}}
{{- .Values.global.customInitContainers -}}
{{- end -}}
{{- if .Values.artifactory.customInitContainers -}}
{{- .Values.artifactory.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "artifactory-ha.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- end -}}
{{- if .Values.artifactory.customVolumes -}}
{{- .Values.artifactory.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedCustomSecretVolumeName value
*/}}
{{- define "artifactory-ha.unifiedCustomSecretVolumeName" -}}
{{- printf "%s-%s" (include "artifactory-ha.name" .) ("unified-secret-volume") | trunc 63 -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory-ha.checkDuplicateUnifiedCustomVolume" -}}
{{- if or .Values.global.customVolumes .Values.artifactory.customVolumes -}}
{{- $val := (tpl (include "artifactory-ha.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory-ha.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts value
*/}}
{{- define "artifactory-ha.customVolumeMounts" -}}
{{- if .Values.global.customVolumeMounts -}}
{{- .Values.global.customVolumeMounts -}}
{{- end -}}
{{- if .Values.artifactory.customVolumeMounts -}}
{{- .Values.artifactory.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "artifactory-ha.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.artifactory.customSidecarContainers -}}
{{- .Values.artifactory.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper artifactory chart image names
*/}}
{{- define "artifactory-ha.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $image := index $dot.Values $indexReference "image" }}
{{- $tag := "" -}}
{{- $digest := "" -}}
{{- if and (eq $indexReference "artifactory") (hasKey $dot.Values "artifactoryService") }}
    {{- if default false $dot.Values.artifactoryService.enabled }}
        {{- $indexReference = "artifactoryService" -}}
        {{- $tag = default $dot.Chart.Annotations.artifactoryServiceVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
        {{- $repositoryName = index $dot.Values $indexReference "image" "repository" -}}
    {{- else -}}
        {{- $tag = default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
    {{- end -}}
{{- end -}}
{{- if and (eq $indexReference "metadata") (hasKey $dot.Values.metadata "standaloneImageEnabled") }}
    {{- if default false $dot.Values.metadata.standaloneImageEnabled }}
        {{- $tag = default $dot.Chart.Annotations.metadataVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
    {{- end -}}
{{- end -}}
{{- if and (eq $indexReference "observability") (hasKey $dot.Values.observability "standaloneImageEnabled") }}
    {{- if default false $dot.Values.observability.standaloneImageEnabled }}
        {{- $tag = default $dot.Chart.Annotations.observabilityVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
    {{- end -}}
{{- end -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.splitServicesToContainers $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.splitServicesToContainers $dot.Values.global.digests.router (eq $indexReference "router") }}
    {{- $digest = $dot.Values.global.digests.router | toString -}}
    {{- end }}
    {{- if and $dot.Values.global.versions.initContainers (eq $indexReference "initContainers") }}
    {{- $tag = $dot.Values.global.versions.initContainers | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.initContainers (eq $indexReference "initContainers") }}
    {{- $digest = $dot.Values.global.digests.initContainers | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.rtfs (eq $indexReference "rtfs") }}
    {{- $tag = $dot.Values.global.versions.rtfs | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.rtfs (eq $indexReference "rtfs") }}
    {{- $digest = $dot.Values.global.digests.rtfs | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.apptrust (eq $indexReference "apptrust") }}
    {{- $tag = $dot.Values.global.versions.apptrust | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.apptrust (eq $indexReference "apptrust") }}
    {{- $digest = $dot.Values.global.digests.apptrust | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.jfbus (eq $indexReference "jfbus") }}
    {{- $tag = $dot.Values.global.versions.jfbus | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.jfbus (eq $indexReference "jfbus") }}
    {{- $digest = $dot.Values.global.digests.jfbus | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.platformfederation (eq $indexReference "platformfederation") }}
    {{- $tag = $dot.Values.global.versions.platformfederation | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.platformfederation (eq $indexReference "platformfederation") }}
    {{- $digest = $dot.Values.global.digests.platformfederation | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.unifiedpolicy (eq $indexReference "unifiedpolicy") }}
    {{- $tag = $dot.Values.global.versions.unifiedpolicy | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.unifiedpolicy (eq $indexReference "unifiedpolicy") }}
    {{- $digest = $dot.Values.global.digests.unifiedpolicy | toString -}}
    {{- end -}}
    {{- if $dot.Values.global.versions.artifactory }}
        {{- if or (eq $indexReference "artifactory") (eq $indexReference "metadata") (eq $indexReference "nginx") }}
            {{- $tag = $dot.Values.global.versions.artifactory | toString -}}
        {{- end -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.artifactory (eq $indexReference "artifactory") }}
    {{- $digest = $dot.Values.global.digests.artifactory | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.metadata (eq $indexReference "metadata") }}
    {{- $digest = $dot.Values.global.digests.metadata | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.observability (eq $indexReference "observability") }}
    {{- $tag = $dot.Values.global.versions.observability | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.observability (eq $indexReference "observability") }}
    {{- $digest = $dot.Values.global.digests.observability | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.nginx (eq $indexReference "nginx") }}
    {{- $digest = $dot.Values.global.digests.nginx | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.filebeat (eq $indexReference "filebeat") }}
    {{- $tag = $dot.Values.global.versions.filebeat | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.filebeat (eq $indexReference "filebeat") }}
    {{- $digest = $dot.Values.global.digests.filebeat | toString -}}
    {{- end -}}
    {{- if and (eq $digest "") (eq $tag "") }}
    {{- $digest = $image.digest }}
    {{- $tag = default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
    {{- end -}}
    {{- if $dot.Values.global.imageRegistry }}
      {{- if $digest }}
          {{- printf "%s/%s@%s" $dot.Values.global.imageRegistry $repositoryName $digest -}}
      {{- else -}}
        {{- printf "%s/%s:%s" $dot.Values.global.imageRegistry $repositoryName $tag -}}
      {{- end -}}
    {{- else -}}
      {{- if $digest }}
        {{- printf "%s/%s@%s" $registryName $repositoryName $digest -}}
      {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
      {{- end -}}
    {{- end -}}
{{- else -}}
  {{- if and (eq $digest "") (eq $tag "") }}
  {{- $digest = $image.digest }}
  {{- $tag = default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
  {{- end -}}
  {{- if $digest }}
    {{- printf "%s/%s@%s" $registryName $repositoryName $digest -}}
  {{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper artifactory app version
*/}}
{{- define "artifactory-ha.app.version" -}}
{{- $tag := (splitList ":" ((include "artifactory-ha.getImageInfoByValue" (list . "artifactory" )))) | last | toString -}}
{{- printf "%s" $tag -}}
{{- end -}}

{{/*
Return the proper artifactory app version
*/}}
{{- define "artifactory-ha.application.version" -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "artifactory-ha.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
Circle of trust certificates copy command
*/}}
{{- define "artifactory.copyCircleOfTrustCertsCerts" -}}
echo "Copy circle of trust certificates to {{ .Values.artifactory.persistence.mountPath }}/etc/access/keys/trusted";
mkdir -p {{ .Values.artifactory.persistence.mountPath }}/etc/access/keys/trusted;
for file in $(ls -1 /tmp/circleoftrustcerts/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.artifactory.persistence.mountPath }}/etc/access/keys/trusted; fi done;
{{- end -}}

{{/*
Resolve requiredServiceTypes value
*/}}
{{- define "artifactory-ha.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfrt,jfac" -}}
{{- if not .Values.access.enabled -}}
  {{- $requiredTypes = "jfrt" -}}
{{- end -}}
{{- if .Values.observability.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfob" -}}
{{- end -}}
{{- if .Values.metadata.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfmd" -}}
{{- end -}}
{{- if .Values.event.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfevt" -}}
{{- end -}}
{{- if .Values.frontend.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jffe" -}}
{{- end -}}
{{- if .Values.jfconnect.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfcon" -}}
{{- end -}}
{{- if .Values.evidence.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfevd" -}}
{{- end -}}
{{- if .Values.topology.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jftpl" -}}
{{- end -}}
{{- if .Values.jfconfig.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfcfg" -}}
{{- end -}}
{{- if .Values.mc.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfmc" -}}
{{- end -}}
{{- if .Values.onemodel.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfomr" -}}
{{- end -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
nginx scheme (http/https)
*/}}
{{- define "nginx.scheme" -}}
{{- if .Values.nginx.http.enabled -}}
{{- printf "%s" "http" -}}
{{- else -}}
{{- printf "%s" "https" -}}
{{- end -}}
{{- end -}}


{{/*
nginx command
*/}}
{{- define "nginx.command" -}}
{{- if .Values.nginx.customCommand }}
{{  toYaml .Values.nginx.customCommand }}
{{- end }}
{{- end -}}

{{/*
nginx port (8080/8443) based on http/https enabled
*/}}
{{- define "nginx.port" -}}
{{- if .Values.nginx.http.enabled -}}
{{- .Values.nginx.http.internalPort -}}
{{- else -}}
{{- .Values.nginx.https.internalPort -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainers value
*/}}
{{- define "artifactory.nginx.customInitContainers" -}}
{{- if .Values.nginx.customInitContainers -}}
{{- .Values.nginx.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "artifactory.nginx.customVolumes" -}}
{{- if .Values.nginx.customVolumes -}}
{{- .Values.nginx.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts nginx value
*/}}
{{- define "artifactory.nginx.customVolumeMounts" -}}
{{- if .Values.nginx.customVolumeMounts -}}
{{- .Values.nginx.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customSidecarContainers value
*/}}
{{- define "artifactory.nginx.customSidecarContainers" -}}
{{- if .Values.nginx.customSidecarContainers -}}
{{- .Values.nginx.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve Artifactory pod primary node selector value
*/}}
{{- define "artifactory.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.artifactory.primary.nodeSelector }}
{{ toYaml .Values.artifactory.primary.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve Artifactory pod node nodeselector value
*/}}
{{- define "artifactory.node.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.artifactory.node.nodeSelector }}
{{ toYaml .Values.artifactory.node.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve Nginx pods node selector value
*/}}
{{- define "nginx.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.nginx.nodeSelector }}
{{ toYaml .Values.nginx.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Calculate the systemYaml from structured and unstructured text input
*/}}
{{- define "artifactory.finalSystemYaml" -}}
{{ tpl (mergeOverwrite (include "artifactory.systemYaml" . | fromYaml) .Values.artifactory.extraSystemYaml | toYaml) . }}
{{- end -}}

{{/*
Calculate the systemYaml from the unstructured text input
*/}}
{{- define "artifactory.systemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}

{{/*
Metrics enabled
*/}}
{{- define "metrics.enabled" -}}
  metrics:
    enabled: true
{{- end }}

{{/*
Resolve artifactory metrics
*/}}
{{- define "artifactory.metrics" -}}
{{- if .Values.artifactory.openMetrics -}} 
{{- if .Values.artifactory.openMetrics.enabled -}}
{{ include "metrics.enabled" . }}
{{- if .Values.artifactory.openMetrics.filebeat }}
{{- if .Values.artifactory.openMetrics.filebeat.enabled }}
{{ include "metrics.enabled" . }}
    filebeat:
{{ tpl (.Values.artifactory.openMetrics.filebeat | toYaml) . | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else if .Values.artifactory.metrics -}}
{{- if .Values.artifactory.metrics.enabled -}}
{{ include "metrics.enabled" . }}
{{- if .Values.artifactory.metrics.filebeat }}
{{- if .Values.artifactory.metrics.filebeat.enabled }}
{{ include "metrics.enabled" . }}
    filebeat:
{{ tpl (.Values.artifactory.metrics.filebeat | toYaml) . | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve unified secret prepend release name
*/}}
{{- define "artifactory.unifiedSecretPrependReleaseName" -}}
{{- if .Values.artifactory.unifiedSecretPrependReleaseName }}
{{- printf "%s" (include "artifactory-ha.fullname" .) -}}
{{- else }}
{{- printf "%s" (include "artifactory-ha.name" .) -}}
{{- end }}
{{- end }}

{{/*
Resolve nginx hosts value
*/}}
{{- define "artifactory.nginx.hosts" -}}
{{- if .Values.ingress.hosts }}
{{- range .Values.ingress.hosts -}}
  {{- if contains "." . -}}
    {{ "" | indent 0 }} ~(?<repo>.+)\.{{ . }}
  {{- end -}}
{{- end -}}
{{- else if .Values.nginx.hosts }}
{{- range .Values.nginx.hosts -}}
  {{- if contains "." . -}}
    {{ "" | indent 0 }} ~(?<repo>.+)\.{{ . }}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified grpc ingress name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "artifactory.ingressGrpc.fullname" -}}
{{- printf "%s-%s" (include "artifactory-ha.fullname" .) .Values.ingressGrpc.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified grpc service name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "artifactory.serviceGrpc.fullname" -}}
{{- printf "%s-%s" (include "artifactory-ha.fullname" .) .Values.artifactory.serviceGrpc.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolve Artifactory autoscalling metrics
*/}}
{{- define "artifactory-ha.hpametrics" -}}
{{- if .Values.autoscaling.metrics -}}
{{- .Values.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "rtfs.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.rtfs.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.rtfs.name -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
    Resolve jfrogUrl value
*/}}
{{- define "rtfs.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.rtfs.jfrogUrl -}}
{{- .Values.rtfs.jfrogUrl -}}
{{- else -}}
{{- printf "http://%s:8082" (include "artifactory-ha.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Resolve RTFS customSidecarContainers value
*/}}
{{- define "artifactory.rtfs.customSidecarContainers" -}}
{{- if .Values.rtfs.customSidecarContainers -}}
{{- .Values.rtfs.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve RTFS customInitContainers value
*/}}
{{- define "artifactory.rtfs.customInitContainers" -}}
{{- if .Values.rtfs.customInitContainers -}}
{{- .Values.rtfs.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "artifactory.rtfs.customVolumes" -}}
{{- if .Values.rtfs.customVolumes -}}
{{- .Values.rtfs.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Rtfs command
*/}}
{{- define "rtfs.command" -}}
{{- if .Values.rtfs.customCommand }}
{{  toYaml .Values.rtfs.customCommand }}
{{- end }}
{{- end -}}

{{/*
Resolve customVolumeMounts rtfs value
*/}}
{{- define "artifactory.rtfs.customVolumeMounts" -}}
{{- if .Values.rtfs.customVolumeMounts -}}
{{- .Values.rtfs.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve RTFS autoscalling metrics
*/}}
{{- define "rtfs.metrics" -}}
{{- if .Values.rtfs.autoscaling.metrics -}}
{{- .Values.rtfs.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "apptrust.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.apptrust.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.apptrust.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
    Resolve jfrogUrl value
*/}}
{{- define "apptrust.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.apptrust.jfrogUrl -}}
{{- .Values.apptrust.jfrogUrl -}}
{{- else -}}
{{- printf "http://%s:%s" (include "artifactory-ha.fullname" .) (toString .Values.router.externalPort) -}}
{{- end -}}
{{- end -}}

{{/*
Resolve apptrust customSidecarContainers value
*/}}
{{- define "artifactory.apptrust.customSidecarContainers" -}}
{{- if .Values.apptrust.customSidecarContainers -}}
{{- .Values.apptrust.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve apptrust customInitContainers value
*/}}
{{- define "artifactory.apptrust.customInitContainers" -}}
{{- if .Values.apptrust.customInitContainers -}}
{{- .Values.apptrust.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "artifactory.apptrust.customVolumes" -}}
{{- if .Values.apptrust.customVolumes -}}
{{- .Values.apptrust.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
apptrust command
*/}}
{{- define "apptrust.command" -}}
{{- if .Values.apptrust.customCommand }}
{{  toYaml .Values.apptrust.customCommand }}
{{- end }}
{{- end -}}

{{/*
Resolve customVolumeMounts apptrust value
*/}}
{{- define "artifactory.apptrust.customVolumeMounts" -}}
{{- if .Values.apptrust.customVolumeMounts -}}
{{- .Values.apptrust.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve apptrust autoscalling metrics
*/}}
{{- define "apptrust.metrics" -}}
{{- if .Values.apptrust.autoscaling.metrics -}}
{{- .Values.apptrust.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "unifiedpolicy.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.unifiedpolicy.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.unifiedpolicy.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
    Resolve jfrogUrl value
*/}}
{{- define "unifiedpolicy.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.unifiedpolicy.jfrogUrl -}}
{{- .Values.unifiedpolicy.jfrogUrl -}}
{{- else -}}
{{- printf "http://%s:%s" (include "artifactory-ha.fullname" .) (toString .Values.router.externalPort) -}}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedpolicy customSidecarContainers value
*/}}
{{- define "artifactory.unifiedpolicy.customSidecarContainers" -}}
{{- if .Values.unifiedpolicy.customSidecarContainers -}}
{{- .Values.unifiedpolicy.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedpolicy customInitContainers value
*/}}
{{- define "artifactory.unifiedpolicy.customInitContainers" -}}
{{- if .Values.unifiedpolicy.customInitContainers -}}
{{- .Values.unifiedpolicy.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "artifactory.unifiedpolicy.customVolumes" -}}
{{- if .Values.unifiedpolicy.customVolumes -}}
{{- .Values.unifiedpolicy.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
unifiedpolicy command
*/}}
{{- define "unifiedpolicy.command" -}}
{{- if .Values.unifiedpolicy.customCommand }}
{{  toYaml .Values.unifiedpolicy.customCommand }}
{{- end }}
{{- end -}}

{{/*
Resolve customVolumeMounts unifiedpolicy value
*/}}
{{- define "artifactory.unifiedpolicy.customVolumeMounts" -}}
{{- if .Values.unifiedpolicy.customVolumeMounts -}}
{{- .Values.unifiedpolicy.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedpolicy autoscalling metrics
*/}}
{{- define "unifiedpolicy.metrics" -}}
{{- if .Values.unifiedpolicy.autoscaling.metrics -}}
{{- .Values.unifiedpolicy.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Return true if both AWS S3 V3 identitySecret and credentialSecret are configured with non-empty values
*/}}
{{- define "artifactory-ha.awsS3V3SecretsConfigured" -}}
{{- $s3 := .Values.artifactory.persistence.awsS3V3 | default dict -}}
{{- $identity := $s3.identitySecret | default dict -}}
{{- $credential := $s3.credentialSecret | default dict -}}
{{- if and (kindIs "map" $identity)
           (kindIs "map" $credential)
           $identity.name
           $identity.key
           $credential.name
           $credential.key -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{/*
Return true if both Azure Blob accountNameSecret and accountKeySecret are properly configured with non-empty values
*/}}
{{- define "artifactory-ha.azureBlobSecretsConfigured" -}}
{{- $blob := .Values.artifactory.persistence.azureBlob | default dict -}}
{{- $accountNameSecret := $blob.accountNameSecret | default dict -}}
{{- $accountKeySecret := $blob.accountKeySecret | default dict -}}
{{- if and 
      (kindIs "map" $accountNameSecret)
      (kindIs "map" $accountKeySecret)
      $accountNameSecret.name
      $accountNameSecret.key
      $accountKeySecret.name
      $accountKeySecret.key -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}


{{/*
Create a default fully qualified JFbus name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "jfbus.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.jfbus.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.jfbus.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFbus customVolumes value
*/}}
{{- define "artifactory.jfbus.customVolumes" -}}
{{- if .Values.jfbus.customVolumes -}}
{{- .Values.jfbus.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve Artifactory autoscalling metrics
*/}}
{{- define "artifactory.hpametrics" -}}
{{- if .Values.autoscaling.metrics -}}
{{- .Values.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
JFbus command
*/}}
{{- define "jfbus.command" -}}
{{- if .Values.jfbus.customCommand }}
{{ toYaml .Values.jfbus.customCommand }}
{{- end }}
{{- end -}}

{{/*
Resolve jfrogUrl for JFbus service
*/}}
{{- define "jfbus.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfbus.jfrogUrl -}}
{{- .Values.jfbus.jfrogUrl -}}
{{- else -}}
{{- printf "http://%s:8082" (include "artifactory-ha.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFbus customVolumeMounts value
*/}}
{{- define "artifactory.jfbus.customVolumeMounts" -}}
{{- if .Values.jfbus.customVolumeMounts -}}
{{- .Values.jfbus.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFbus customSidecarContainers value
*/}}
{{- define "artifactory.jfbus.customSidecarContainers" -}}
{{- if .Values.jfbus.customSidecarContainers -}}
{{- .Values.jfbus.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFbus customInitContainers value
*/}}
{{- define "artifactory.jfbus.customInitContainers" -}}
{{- if .Values.jfbus.customInitContainers -}}
{{- .Values.jfbus.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFbus autoscalling metrics
*/}}
{{- define "jfbus.metrics" -}}
{{- if .Values.jfbus.autoscaling.metrics -}}
{{- .Values.jfbus.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/* PlatformFederation */}}
{{/*
Create a default fully qualified PlatformFederation name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "platformfederation.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.platformfederation.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.platformfederation.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve PlatformFederation customVolumes value
*/}}
{{- define "artifactory.platformfederation.customVolumes" -}}
{{- if .Values.platformfederation.customVolumes -}}
{{- .Values.platformfederation.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
PlatformFederation command
*/}}
{{- define "platformfederation.command" -}}
{{- if .Values.platformfederation.customCommand }}
{{ toYaml .Values.platformfederation.customCommand }}
{{- end }}
{{- end -}}

{{/*
Resolve jfrogUrl for PlatformFederation service
*/}}
{{- define "platformfederation.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.platformfederation.jfrogUrl -}}
{{- .Values.platformfederation.jfrogUrl -}}
{{- else -}}
{{- printf "http://%s:%s" (include "artifactory-ha.fullname" .) (toString .Values.router.externalPort) -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts platformfederation value
*/}}
{{- define "artifactory.platformfederation.customVolumeMounts" -}}
{{- if .Values.platformfederation.customVolumeMounts -}}
{{- .Values.platformfederation.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve PlatformFederation customSidecarContainers value
*/}}
{{- define "artifactory.platformfederation.customSidecarContainers" -}}
{{- if .Values.platformfederation.customSidecarContainers -}}
{{- .Values.platformfederation.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve PlatformFederation customInitContainers value
*/}}
{{- define "artifactory.platformfederation.customInitContainers" -}}
{{- if .Values.platformfederation.customInitContainers -}}
{{- .Values.platformfederation.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve PlatformFederation autoscalling metrics
*/}}
{{- define "platformfederation.metrics" -}}
{{- if .Values.platformfederation.autoscaling.metrics -}}
{{- .Values.platformfederation.autoscaling.metrics -}}
{{- end -}}
{{- end -}}
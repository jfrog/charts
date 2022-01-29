{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "artifactory.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name nginx service.
*/}}
{{- define "artifactory.nginx.name" -}}
{{- default .Chart.Name .Values.nginx.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "artifactory.fullname" -}}
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
Create a default fully qualified replicator app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "artifactory.replicator.fullname" -}}
{{- if .Values.artifactory.replicator.ingress.name -}}
{{- .Values.artifactory.replicator.ingress.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-replication" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified replicator tracker ingress name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "artifactory.replicator.tracker.fullname" -}}
{{- if .Values.artifactory.replicator.trackerIngress.name -}}
{{- .Values.artifactory.replicator.trackerIngress.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-replication-tracker" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified nginx name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "artifactory.nginx.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.nginx.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "artifactory.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "artifactory.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "artifactory.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate SSL certificates
*/}}
{{- define "artifactory.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "artifactory.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "artifactory.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "artifactory-ca" 365 -}}
{{- $cert := genSignedCert ( include "artifactory.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "artifactory.scheme" -}}
{{- if .Values.access.accessConfig.security.tls -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "artifactory.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.artifactory.joinKey -}}
{{- .Values.artifactory.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfConnectToken value
*/}}
{{- define "artifactory.jfConnectToken" -}}
{{- .Values.artifactory.jfConnectToken -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "artifactory.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.artifactory.masterKey -}}
{{- .Values.artifactory.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "artifactory.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.artifactory.joinKeySecretName -}}
{{- .Values.artifactory.joinKeySecretName -}}
{{- else -}}
{{ include "artifactory.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve jfConnectTokenSecretName value
*/}}
{{- define "artifactory.jfConnectTokenSecretName" -}}
{{- if .Values.artifactory.jfConnectTokenSecretName -}}
{{- .Values.artifactory.jfConnectTokenSecretName -}}
{{- else -}}
{{ include "artifactory.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "artifactory.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.artifactory.masterKeySecretName -}}
{{- .Values.artifactory.masterKeySecretName -}}
{{- else -}}
{{ include "artifactory.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "artifactory.imagePullSecrets" -}}
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
{{- define "artifactory.customInitContainersBegin" -}}
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
{{- define "artifactory.customInitContainers" -}}
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
{{- define "artifactory.customVolumes" -}}
{{- if .Values.global.customVolumes -}}
{{- .Values.global.customVolumes -}}
{{- end -}}
{{- if .Values.artifactory.customVolumes -}}
{{- .Values.artifactory.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts value
*/}}
{{- define "artifactory.customVolumeMounts" -}}
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
{{- define "artifactory.customSidecarContainers" -}}
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
{{- define "artifactory.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.splitServicesToContainers $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.artifactory (or (eq $indexReference "artifactory") (eq $indexReference "nginx") ) }}
    {{- $tag = $dot.Values.global.versions.artifactory | toString -}}
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
Return the proper artifactory app version
*/}}
{{- define "artifactory.app.version" -}}
{{- $image := split ":" ((include "artifactory.getImageInfoByValue" (list . "artifactory")) | toString) -}}
{{- $tag := $image._1 -}}
{{- printf "%s" $tag -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "artifactory.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted;
find /tmp/certs -type f -not -name "*.key" -exec cp -v {} {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted \;;
find {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted/ -type f -name "tls.crt" -exec mv -v {} {{ .Values.artifactory.persistence.mountPath }}/etc/security/keys/trusted/ca.crt \;;
{{- end -}}

{{/*
Resolve requiredServiceTypes value
*/}}
{{- define "artifactory.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfrt,jfac,jfmd,jffe,jfevt,jfob,jfint" -}}
{{- if .Values.jfconnect -}}
  {{- if .Values.jfconnect.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfcon" -}}
  {{- end -}}
{{- end -}}
{{- if or .Values.artifactory.replicator.enabled .Values.artifactory.replicator.pdn.tracker.enabled -}}
    {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfxfer" -}}
{{- end -}}
{{- if .Values.mc -}}
  {{- if .Values.mc.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfmc" -}}
  {{- end -}}
{{- end -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Check if the image is artifactory pro or not
*/}}
{{- define "artifactory.isImageProType" -}}
{{- if not (regexMatch "^.*(oss|cpp-ce|jcr).*$" .Values.artifactory.image.repository) -}}
{{ true }}
{{- else -}}
{{ false }}
{{- end -}}
{{- end -}}

{{/*
Check if the artifactory is using derby database
*/}}
{{- define "artifactory.isUsingDerby" -}}
{{- if and (eq (default "derby" .Values.database.type) "derby") (not .Values.postgresql.enabled) -}}
{{ true }}
{{- else -}}
{{ false }}
{{- end -}}
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
nginx port (80/443) based on http/https enabled
*/}}
{{- define "nginx.port" -}}
{{- if .Values.nginx.http.enabled -}}
{{- .Values.nginx.http.internalPort -}}
{{- else -}}
{{- .Values.nginx.https.internalPort -}}
{{- end -}}
{{- end -}}

{{/*
artifactory liveness probe
*/}}
{{- define "artifactory.livenessProbe" -}}
{{- if or .Values.newProbes .Values.splitServicesToContainers -}}
{{- printf "%s" "/artifactory/api/v1/system/liveness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
artifactory readiness probe
*/}}
{{- define "artifactory.readinessProbe" -}}
{{- if or .Values.newProbes .Values.splitServicesToContainers -}}
{{- printf "%s" "/artifactory/api/v1/system/readiness" -}}
{{- else -}}
{{- printf "%s" "/router/api/v1/system/health" -}}
{{- end -}}
{{- end -}}

{{/*
artifactory port
*/}}
{{- define "artifactory.port" -}}
{{- if or .Values.newProbes .Values.splitServicesToContainers -}}
{{- .Values.artifactory.internalArtifactoryPort -}}
{{- else -}}
{{- .Values.router.internalPort  -}}
{{- end -}}
{{- end -}}

{{/*
replicator/tracker
*/}}
{{- define "artifactory.replicator" -}}
{{- if and .Values.artifactory.replicator.enabled .Values.artifactory.replicator.pdn.tracker.enabled -}}
replicator:
  pdn:
    tracker:
      enabled: true
  enabled: true
{{- else if and (not .Values.artifactory.replicator.enabled) .Values.artifactory.replicator.pdn.tracker.enabled -}}
replicator:
  pdn:
    tracker:
      enabled: true
{{- else if and (not .Values.artifactory.replicator.pdn.tracker.enabled) .Values.artifactory.replicator.enabled -}}
replicator:
  enabled: true
{{- end -}}
{{- end -}}

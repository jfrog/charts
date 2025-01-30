{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "xray.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-analysis name
*/}}
{{- define "xray-analysis.name" -}}
{{- default .Chart.Name .Values.analysis.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-sbom name
*/}}
{{- define "xray-sbom.name" -}}
{{- default .Chart.Name .Values.sbom.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-panoramic name
*/}}
{{- define "xray-panoramic.name" -}}
{{- default .Chart.Name .Values.panoramic.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-policyenforcer name
*/}}
{{- define "xray-policyenforcer.name" -}}
{{- default .Chart.Name .Values.panoramic.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-indexer name
*/}}
{{- define "xray-indexer.name" -}}
{{- default .Chart.Name .Values.indexer.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-persist name
*/}}
{{- define "xray-persist.name" -}}
{{- default .Chart.Name .Values.persist.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The xray-server name
*/}}
{{- define "xray-server.name" -}}
{{- default .Chart.Name .Values.server.name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray.fullname" -}}
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
Expand the name of rabbit chart.
*/}}
{{- define "rabbitmq.name" -}}
{{- default (printf "%s" "rabbitmq") .Values.rabbitmq.nameOverride -}}
{{- end -}}

{{- define "xray.rabbitmq.migration.isHookRegistered" }}
{{- or .Values.rabbitmq.migration.enabled .Values.rabbitmq.migration.deleteStatefulSetToAllowFieldUpdate.enabled .Values.rabbitmq.migration.removeHaPolicyOnMigrationToHaQuorum.enabled }}
{{- end }}

{{- define "xray.rabbitmq.migration.fullname" -}}
{{- $name := default "rabbitmq-migration" -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xray-analysis.fullname" -}}
{{- if .Values.analysis.fullnameOverride -}}
{{- .Values.analysis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.analysis.name -}}
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
{{- define "xray-sbom.fullname" -}}
{{- if .Values.sbom.fullnameOverride -}}
{{- .Values.sbom.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.sbom.name -}}
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
{{- define "xray-indexer.fullname" -}}
{{- if .Values.indexer.fullnameOverride -}}
{{- .Values.indexer.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.indexer.name -}}
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
{{- define "xray-persist.fullname" -}}
{{- if .Values.persist.fullnameOverride -}}
{{- .Values.persist.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.persist.name -}}
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
{{- define "xray-server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.server.name -}}
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
{{- define "xray.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "xray.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

Create the name of the service account to use for rabbitmq migration
*/}}
{{- define "xray.rabbitmq.migration.serviceAccountName" -}}
{{- if .Values.rabbitmq.migration.serviceAccount.create -}}
{{ default (include "xray.rabbitmq.migration.fullname" .) .Values.rabbitmq.migration.serviceAccount.name }}
{{- else -}}
{{ default "rabbitmq-migration" .Values.rabbitmq.migration.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "xray.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create rabbitmq URL
*/}}
{{- define "rabbitmq.url" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- if .Values.rabbitmq.auth.tls.enabled -}}
{{- $rabbitmqPort := .Values.rabbitmq.service.ports.amqpTls -}}
{{- $name := default (printf "%s" "rabbitmq") .Values.rabbitmq.nameOverride -}}
{{- printf "%s://%s-%s:%g/" "amqps" .Release.Name $name $rabbitmqPort -}}
{{- else -}}
{{- $rabbitmqPort := .Values.rabbitmq.service.ports.amqp -}}
{{- $name := default (printf "%s" "rabbitmq") .Values.rabbitmq.nameOverride -}}
{{- printf "%s://%s-%s:%g/" "amqp" .Release.Name $name $rabbitmqPort -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create rabbitmq username
*/}}
{{- define "rabbitmq.user" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- .Values.rabbitmq.auth.username -}}
{{- end -}}
{{- end -}}

{{/*
Create rabbitmq URL with user and password
*/}}
{{- define "rabbitmq.urlWithCreds" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- $name := default (printf "%s" "rabbitmq") .Values.rabbitmq.nameOverride -}}
{{- $local_svc := default (printf "%s" "svc.cluster.local") -}}
{{- if .Values.rabbitmq.auth.tls.enabled -}}
{{- $rabbitmqPort := .Values.rabbitmq.service.ports.amqpTls -}}
{{- printf "%s://%s:%s@%s-%s.%s.%s:%g" "amqps" .Values.rabbitmq.auth.username .Values.rabbitmq.auth.password .Release.Name $name .Release.Namespace $local_svc $rabbitmqPort -}}
{{- else -}}
{{- $rabbitmqPort := .Values.rabbitmq.service.ports.amqp -}}
{{- printf "%s://%s:%s@%s-%s.%s.%s:%g" "amqp" .Values.rabbitmq.auth.username .Values.rabbitmq.auth.password .Release.Name $name .Release.Namespace $local_svc $rabbitmqPort -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create rabbitmq password secret name
*/}}
{{- define "rabbitmq.passwordSecretName" -}}
{{- if index .Values "rabbitmq" "enabled" -}}
{{- $name := default (printf "%s" "rabbitmq") .Values.rabbitmq.nameOverride -}}
{{- .Values.rabbitmq.auth.existingPasswordSecret | default (printf "%s-%s" .Release.Name $name) -}}
{{- end -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access TLS enabled/disabled
*/}}
{{- define "xray.scheme" -}}
{{- if .Values.router.tlsEnabled -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "xray.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.xray.jfrogUrl -}}
{{- .Values.xray.jfrogUrl -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKey value
*/}}
{{- define "xray.joinKey" -}}
{{- if .Values.global.joinKey -}}
{{- .Values.global.joinKey -}}
{{- else if .Values.xray.joinKey -}}
{{- .Values.xray.joinKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKey value
*/}}
{{- define "xray.masterKey" -}}
{{- if .Values.global.masterKey -}}
{{- .Values.global.masterKey -}}
{{- else if .Values.xray.masterKey -}}
{{- .Values.xray.masterKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve joinKeySecretName value
*/}}
{{- define "xray.joinKeySecretName" -}}
{{- if .Values.global.joinKeySecretName -}}
{{- .Values.global.joinKeySecretName -}}
{{- else if .Values.xray.joinKeySecretName -}}
{{- .Values.xray.joinKeySecretName -}}
{{- else -}}
{{ include "xray.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve masterKeySecretName value
*/}}
{{- define "xray.masterKeySecretName" -}}
{{- if .Values.global.masterKeySecretName -}}
{{- .Values.global.masterKeySecretName -}}
{{- else if .Values.xray.masterKeySecretName -}}
{{- .Values.xray.masterKeySecretName -}}
{{- else -}}
{{ include "xray.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve executionServiceAesKeySecretName value
*/}}
{{- define "xray.executionServiceAesKeySecretName" -}}
{{- if .Values.global.executionServiceAesKeySecretName -}}
{{- .Values.global.executionServiceAesKeySecretName -}}
{{- else if .Values.xray.executionServiceAesKeySecretName -}}
{{- .Values.xray.executionServiceAesKeySecretName -}}
{{- else -}}
{{ include "xray.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Resolve imagePullSecrets value
*/}}
{{- define "xray.imagePullSecrets" -}}
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
Resolve imagePullSecretsStrList value
*/}}
{{- define "xray.imagePullSecretsStrList" -}}
{{- if .Values.global.imagePullSecrets }}
{{- range .Values.global.imagePullSecrets }}
- {{ . }}
{{- end }}
{{- else if .Values.imagePullSecrets }}
{{- range .Values.imagePullSecrets }}
- {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Resolve customInitContainersBegin value
*/}}
{{- define "xray.customInitContainersBegin" -}}
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
{{- define "xray.customInitContainers" -}}
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
{{- define "xray.customVolumes" -}}
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
{{- define "xray.customVolumeMounts" -}}
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
{{- define "xray.customSidecarContainers" -}}
{{- if .Values.global.customSidecarContainers -}}
{{- .Values.global.customSidecarContainers -}}
{{- end -}}
{{- if .Values.common.customSidecarContainers -}}
{{- .Values.common.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper xray chart image names
*/}}
{{- define "xray.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $tag := default $dot.Chart.AppVersion (index $dot.Values $indexReference "image" "tag") | toString -}}
{{- if and $dot.Values.common.xrayVersion (or (eq $indexReference "persist") (eq $indexReference "server") (eq $indexReference "analysis") (eq $indexReference "sbom") (eq $indexReference "indexer") (eq $indexReference "policyenforcer") (eq $indexReference "panoramic")) }}
{{- $tag = $dot.Values.common.xrayVersion | toString -}}
{{- end -}}
{{- if $dot.Values.global }}
    {{- if and $dot.Values.global.versions.router (eq $indexReference "router") }}
    {{- $tag = $dot.Values.global.versions.router | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.initContainers (eq $indexReference "initContainers") }}
    {{- $tag = $dot.Values.global.versions.initContainers | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.xray (or (eq $indexReference "persist") (eq $indexReference "server") (eq $indexReference "analysis") (eq $indexReference "sbom") (eq $indexReference "indexer") (eq $indexReference "policyenforcer") (eq $indexReference "panoramic")) }}
    {{- $tag = $dot.Values.global.versions.xray | toString -}}
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
Return the proper xray app version
*/}}
{{- define "xray.app.version" -}}
{{- $tag := (splitList ":" ((include "xray.getImageInfoByValue" (list . "server" )))) | last | toString -}}
{{- printf "%s" $tag -}}
{{- end -}}

{{/*
Return the registry of a service
*/}}
{{- define "xray.getRegistryByService" -}}
{{- $dot := index . 0 }}
{{- $service := index . 1 }}
{{- if $dot.Values.global.imageRegistry }}
    {{- $dot.Values.global.imageRegistry }}
{{- else -}}
    {{- if (eq $service "migrationHook") -}}
      {{- index $dot.Values.rabbitmq.migration.image.registry -}}
   {{- else -}}
      {{- index $dot.Values $service "image" "registry" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Custom certificate copy command
*/}}
{{- define "xray.copyCustomCerts" -}}
{{- if or .Values.xray.customCertificates.enabled .Values.global.customCertificates.enabled -}}
echo "Copy custom certificates to {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}
{{- end -}}

{{/*
Custom Rabbitmq certificate copy command
*/}}
{{- define "xray.copyRabbitmqCustomCerts" -}}
{{- if or .Values.rabbitmq.auth.tls.enabled .Values.global.rabbitmq.auth.tls.enabled -}}
echo "Copy rabbitmq custom certificates to {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted {{ .Values.xray.persistence.mountPath }}/data/rabbitmq/certs/;
cd /tmp/rabbitmqcerts/;
for file in $(ls * | grep -v ".key" | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.xray.persistence.mountPath }}/etc/security/keys/trusted/rabbitmq_${file}; fi done;
for file in $(ls * | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.xray.persistence.mountPath }}/data/rabbitmq/certs/rabbitmq_${file}; fi done;
{{- end -}}
{{- end -}}

{{/*
Resolve xray requiredServiceTypes value
*/}}
{{- define "xray.router.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxr,jfxana,jfxidx,jfxpst,jfxpe,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray ipa requiredServiceTypes value
*/}}
{{- define "xray.router.ipa.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxana,jfxidx,jfxpst,jfxpe,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray server requiredServiceTypes value
*/}}
{{- define "xray.router.server.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxr,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve Xray pod node selector value
*/}}
{{- define "xray.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.xray.nodeSelector }}
{{ toYaml .Values.xray.nodeSelector | indent 2 }}
{{- end -}}
{{- end -}}

{{/*
Resolve unifiedCustomSecretVolumeName value
*/}}
{{- define "xray.unifiedCustomSecretVolumeName" -}}
{{- printf "%s-%s" (include "xray.name" .) ("unified-secret-volume") | trunc 63 -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.
*/}}
{{- define "xray.checkDuplicateUnifiedCustomVolume" -}}
{{- if or .Values.global.customVolumes .Values.common.customVolumes -}}
{{- $val := (tpl (include "xray.customVolumes" .) .) | toJson -}}
{{- contains (include "xray.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve executionServiceAesKey value
*/}}
{{- define "xray.executionServiceAesKey" -}}
{{- if .Values.global.executionServiceAesKey -}}
{{- .Values.global.executionServiceAesKey -}}
{{- else if .Values.xray.executionServiceAesKey -}}
{{- .Values.xray.executionServiceAesKey -}}
{{- end -}}
{{- end -}}

{{/*
Resolve autoscalingQueues value
*/}}
{{- define "xray.autoscalingQueues" -}}
{{- if .Values.autoscaling.keda.queues }}
{{- range .Values.autoscaling.keda.queues }}
- type: rabbitmq
  metadata:
    name: "{{- .name -}}-queue"
    protocol: amqp
    queueName: {{ .name }}
    mode: QueueLength
    value: "{{ .value }}"
{{- if $.Values.global.xray.rabbitmq.haQuorum.enabled }}
    vhostName: "{{ $.Values.global.xray.rabbitmq.haQuorum.vhost }}"
{{- end }}
  authenticationRef:
    name: keda-trigger-auth-rabbitmq-conn-xray
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Resolve autoscalingQueues value for ipa
*/}}
{{- define "xray.autoscalingQueuesIpa" -}}
{{- if .Values.autoscalingIpa.keda.queues }}
{{- range .Values.autoscalingIpa.keda.queues }}
- type: rabbitmq
  metadata:
    name: "{{- .name -}}-queue"
    protocol: amqp
    queueName: {{ .name }}
    mode: QueueLength
    value: "{{ .value }}"
{{- if $.Values.global.xray.rabbitmq.haQuorum.enabled }}
    vhostName: "{{ $.Values.global.xray.rabbitmq.haQuorum.vhost }}"
{{- end }}
  authenticationRef:
    name: keda-trigger-auth-rabbitmq-conn-xray
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Resolve autoscalingQueues value for server
*/}}
{{- define "xray.autoscalingQueuesServer" -}}
{{- if .Values.autoscalingServer.keda.queues }}
{{- range .Values.autoscalingServer.keda.queues }}
- type: rabbitmq
  metadata:
    name: "{{- .name -}}-queue"
    protocol: amqp
    queueName: {{ .name }}
    mode: QueueLength
    value: "{{ .value }}"
{{- if $.Values.global.xray.rabbitmq.haQuorum.enabled }}
    vhostName: "{{ $.Values.global.xray.rabbitmq.haQuorum.vhost }}"
{{- end }}
  authenticationRef:
    name: keda-trigger-auth-rabbitmq-conn-xray
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the secret name of rabbitmq TLS certs.
*/}}
{{- define "xray.rabbitmqCustomCertificateshandler" -}}
{{- if .Values.global.rabbitmq.auth.tls.enabled -}}
{{- $secretName := printf "%s-%s" .Release.Name "rabbitmq-certs"  -}}
{{- $val := default $secretName .Values.global.rabbitmq.auth.tls.existingSecret -}}
{{- $val -}}
{{- else if .Values.rabbitmq.auth.tls.enabled -}}
{{- $secretName := printf "%s-%s" .Release.Name "rabbitmq-certs" -}}
{{- $val := default $secretName .Values.rabbitmq.auth.tls.existingSecret -}}
{{- $val -}}
{{- end -}}
{{- end -}}

{{/*
Prints value of Values.rabbitmq.auth.tls.enabled.
*/}}
{{- define "xray.rabbitmq.isManagementListenerTlsEnabledInContext" -}}
{{- printf "%t" $.Values.auth.tls.enabled -}}
{{- end -}}

{{- define "xray.rabbitmq.isManagementListenerTlsEnabled" -}}
{{- printf "%t" $.Values.rabbitmq.auth.tls.enabled -}}
{{- end -}}

{{/*
Set xray env variables if rabbitmq.tls is enabled.
*/}}
{{- define "xray.rabbitmqTlsEnvVariables" -}}
{{- if or .Values.rabbitmq.auth.tls.enabled .Values.global.rabbitmq.auth.tls.enabled }}
- name: GODEBUG
  value: "x509ignoreCN=0"
- name: enableTlsConnectionToRabbitMQ
  value: "true"
- name: RABBITMQ_CERT_FILE_PATH
  value: {{.Values.xray.persistence.mountPath }}/data/rabbitmq/certs/rabbitmq_tls.crt
- name: RABBITMQ_CERT_KEY_FILE_PATH
  value: {{.Values.xray.persistence.mountPath }}/data/rabbitmq/certs/rabbitmq_tls.key
- name: RABBITMQ_CA_CERT_FILE_PATH
  value: {{.Values.xray.persistence.mountPath }}/data/rabbitmq/certs/rabbitmq_ca.crt
{{- end }}
{{- end -}}

{{- define "xray.resolveUsedMasterKeySecretName" -}}
{{- if or .Values.xray.masterKey .Values.xray.masterKeySecretName .Values.global.masterKey .Values.global.masterKeySecretName -}}
{{- if or (not .Values.xray.unifiedSecretInstallation) (or .Values.xray.masterKeySecretName .Values.global.masterKeySecretName) -}}
{{- include "xray.masterKeySecretName" . -}}
{{- else -}}
{{ template "xray.name" . }}-unified-secret
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "xray.resolveUsedJoinKeySecretName" -}}
{{- if or .Values.xray.joinKey .Values.xray.joinKeySecretName .Values.global.joinKey .Values.global.joinKeySecretName -}}
{{- if or (not .Values.xray.unifiedSecretInstallation) (or .Values.xray.joinKeySecretName .Values.global.joinKeySecretName) -}}
{{- include "xray.joinKeySecretName" . -}}
{{- else -}}
{{ template "xray.name" . }}-unified-secret
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "xray.envVariables" }}
- name: XRAY_CHART_FULL_NAME
  value: '{{ include "xray.fullname" . }}'
- name: XRAY_CHART_NAME
  value: '{{ include "xray.name" . }}'
- name: XRAY_CHART_UNIFIED_SECRET_INSTALLATION
  value: "{{ .Values.xray.unifiedSecretInstallation }}"
- name: XRAY_CHART_SYSTEM_YAML_OVERRIDE_EXISTING_SECRET
  value: "{{ .Values.systemYamlOverride.existingSecret }}"
- name: XRAY_CHART_SYSTEM_YAML_OVERRIDE_DATA_KEY
  value: "{{ .Values.systemYamlOverride.dataKey }}"
- name: XRAY_CHART_MASTER_KEY_SECRET_NAME
  value: '{{ include "xray.resolveUsedMasterKeySecretName" . }}'
- name: XRAY_CHART_JOIN_KEY_SECRET_NAME
  value: '{{ include "xray.resolveUsedJoinKeySecretName" . }}'
{{- end }}

{{/*
Calculate the systemYaml from structured and unstructured text input
*/}}
{{- define "xray.finalSystemYaml" -}}
{{- if .Values.xray.extraSystemYaml }}
{{ tpl (mergeOverwrite (include "xray.systemYaml" . | fromYaml) .Values.xray.extraSystemYaml | toYaml) . }}
{{- else }}
{{ include "xray.systemYaml" . }}
{{- end }}
{{- end -}}

{{/*
Calculate the systemYaml from the unstructured text input
*/}}
{{- define "xray.systemYaml" -}}
{{ include (print $.Template.BasePath "/_system-yaml-render.tpl") . }}
{{- end -}}
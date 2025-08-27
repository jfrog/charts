{{/*
Common annotations for the deployments
*/}}
{{- define "xray.annotations" -}}
{{- if not .Values.xray.unifiedSecretInstallation }}
checksum/database-secrets: {{ include (print $.Template.BasePath "/xray-database-secrets.yaml") . | sha256sum }}
checksum/systemyaml: {{ include (print $.Template.BasePath "/xray-system-yaml.yaml") . | sha256sum }}
{{- else }}
checksum/xray-unified-secret: {{ include (print $.Template.BasePath "/xray-unified-secret.yaml") . | sha256sum }}
{{- end }}
{{- end -}}

{{/*
Common labels for the deployments
*/}}
{{- define "xray.labels" -}}
app: {{ template "xray.name" . }}
chart: {{ template "xray.chart" . }}
release: {{ .Release.Name }}
component: {{ .Values.xray.name }}
{{- end -}}

{{/*
Common filebeat configuration for the deployments
*/}}
{{- define "xray.filebeat" -}}
- name: {{ .Values.filebeat.name }}
  image: "{{ .Values.filebeat.image.repository }}:{{ .Values.filebeat.image.version }}"
  imagePullPolicy: {{ .Values.filebeat.image.pullPolicy }}
  args:
  - "-e"
  - "-E"
  - "http.enabled=true"
  {{- if .Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit .Values.containerSecurityContext "enabled" | toYaml) . | nindent 10 }}
  {{- end }}
  volumeMounts:
  - name: filebeat-config
    mountPath: /usr/share/filebeat/filebeat.yml
    readOnly: true
    subPath: filebeat.yml
  - name: data-volume
    mountPath: "{{ .Values.xray.persistence.mountPath }}"
  livenessProbe:
{{ toYaml .Values.filebeat.livenessProbe | indent 10 }}
  readinessProbe:
{{ toYaml .Values.filebeat.readinessProbe | indent 10 }}
  resources:
{{ toYaml .Values.filebeat.resources | indent 10 }}
  terminationGracePeriodSeconds: {{ .Values.terminationGracePeriod }}
{{- end -}}

{{/*
Common spec configuration for the pods
*/}}
{{- define "xray.spec" -}}
{{- if .Values.xray.schedulerName }}
schedulerName: {{ .Values.xray.schedulerName | quote }}
{{- end }}
{{- if or .Values.imagePullSecrets .Values.global.imagePullSecrets }}
{{- include "xray.imagePullSecrets" . }}
{{- end }}
{{- if .Values.xray.priorityClass.existingPriorityClass }}
priorityClassName: {{ .Values.xray.priorityClass.existingPriorityClass }}
{{- else -}}
{{- if .Values.xray.priorityClass.create }}
priorityClassName: {{ default (include "xray.fullname" .) .Values.xray.priorityClass.name }}
{{- end }}
{{- end }}
serviceAccountName: {{ template "xray.serviceAccountName" . }}
{{- if .Values.podSecurityContext.enabled }}
securityContext: {{- omit .Values.podSecurityContext "enabled" | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.common.topologySpreadConstraints }}
topologySpreadConstraints:
{{ tpl (toYaml .Values.common.topologySpreadConstraints) . | indent 2 }}
{{- end }}
{{- end -}}


{{/*
Common initContainers for the pods
*/}}
{{- define "xray.initContainers" -}}
{{- if or .Values.common.customInitContainersBegin .Values.global.customInitContainersBegin }}
{{ tpl (include "xray.customInitContainersBegin" .) . }}
{{- end }}
- name: 'copy-system-yaml'
  image: {{ include "xray.getImageInfoByValue" (list . "initContainers") }}
  imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  {{- if .Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit .Values.containerSecurityContext "enabled" | toYaml) . | nindent 4 }}
  {{- end }}
  resources:
{{ toYaml .Values.initContainers.resources | indent 4 }}
  command:
  - 'bash'
  - '-c'
  - >
    if [[ -e "{{ .Values.xray.persistence.mountPath }}/etc/filebeat.yaml" ]]; then chmod 644 {{ .Values.xray.persistence.mountPath }}/etc/filebeat.yaml; fi;
    echo "Copy system.yaml to {{ .Values.xray.persistence.mountPath }}/etc";
    mkdir -p {{ .Values.xray.persistence.mountPath }}/etc;
    {{- if .Values.systemYamlOverride.existingSecret }}
    cp -fv /tmp/etc/{{ .Values.systemYamlOverride.dataKey }} {{ .Values.xray.persistence.mountPath }}/etc/system.yaml;
    {{- else }}
    cp -fv /tmp/etc/system.yaml {{ .Values.xray.persistence.mountPath }}/etc/system.yaml;
    {{- end }}
    echo "Remove {{ .Values.xray.persistence.mountPath }}/lost+found folder if exists";
    rm -rfv {{ .Values.xray.persistence.mountPath }}/lost+found;
  {{- if or .Values.xray.joinKey .Values.xray.joinKeySecretName .Values.global.joinKey .Values.global.joinKeySecretName }}
    echo "Copy joinKey to {{ .Values.xray.persistence.mountPath }}/etc/security";
    mkdir -p {{ .Values.xray.persistence.mountPath }}/etc/security;
    echo ${XRAY_JOIN_KEY} > {{ .Values.xray.persistence.mountPath }}/etc/security/join.key;
  {{- end }}
  {{- if or .Values.xray.masterKey .Values.xray.masterKeySecretName .Values.global.masterKey .Values.global.masterKeySecretName }}
    echo "Copy masterKey to {{ .Values.xray.persistence.mountPath }}/etc/security";
    mkdir -p {{ .Values.xray.persistence.mountPath }}/etc/security;
    echo ${XRAY_MASTER_KEY} > {{ .Values.xray.persistence.mountPath }}/etc/security/master.key;
  {{- end }}
    if set | grep -q "^XRAY_RABBITMQ_PASSWORD="; then
    echo "Copy rabbitmq password to {{ .Values.xray.persistence.mountPath }}/etc/security";
    mkdir -p {{ .Values.xray.persistence.mountPath }}/etc/security;
    echo ${XRAY_RABBITMQ_PASSWORD} > {{ .Values.xray.persistence.mountPath }}/etc/security/rabbitmq.password;
    else
      if test -f "{{ .Values.xray.persistence.mountPath }}/etc/security/rabbitmq.password"; then
      echo "XRAY_RABBITMQ_PASSWORD is not set, removing existing rabbitmq.password file.";
      rm -f {{ .Values.xray.persistence.mountPath }}/etc/security/rabbitmq.password;
      fi
    fi
  {{ if or .Values.database.secrets.password .Values.database.password .Values.postgresql.enabled }}
    if set | grep -q "^XRAY_POSTGRES_PASSWORD="; then
    echo "Copy postgres password to {{ .Values.xray.persistence.mountPath }}/etc/security";
    mkdir -p {{ .Values.xray.persistence.mountPath }}/etc/security;
    echo ${XRAY_POSTGRES_PASSWORD} > {{ .Values.xray.persistence.mountPath }}/etc/security/postgres.password;
    else
      if test -f "{{ .Values.xray.persistence.mountPath }}/etc/security/postgres.password"; then
      echo "XRAY_POSTGRES_PASSWORD is not set, removing existing postgres.password file.";
      rm -f {{ .Values.xray.persistence.mountPath }}/etc/security/postgres.password;
      fi
    fi
  {{- end }}
  env:
  {{- if or .Values.xray.joinKey .Values.xray.joinKeySecretName .Values.global.joinKey .Values.global.joinKeySecretName }}
  - name: XRAY_JOIN_KEY
    valueFrom:
      secretKeyRef:
        {{- if or (not .Values.xray.unifiedSecretInstallation) (or .Values.xray.joinKeySecretName .Values.global.joinKeySecretName) }}
        name: {{ include "xray.joinKeySecretName" . }}
        {{- else }}
        name: "{{ template "xray.fullname" . }}-unified-secret"
        {{- end }}
        key: join-key
  {{- end }}
  {{- if or .Values.xray.masterKey .Values.xray.masterKeySecretName .Values.global.masterKey .Values.global.masterKeySecretName }}
  - name: XRAY_MASTER_KEY
    valueFrom:
      secretKeyRef:
        {{- if or (not .Values.xray.unifiedSecretInstallation) (or .Values.xray.masterKeySecretName .Values.global.masterKeySecretName) }}
        name: {{ include "xray.masterKeySecretName" . }}
        {{- else }}
        name: "{{ template "xray.fullname" . }}-unified-secret"
        {{- end }}
        key: master-key
  {{- end }}
  {{- if and .Values.rabbitmq.external.secrets (not .Values.common.rabbitmq.connectionConfigFromEnvironment) }}
  - name: XRAY_RABBITMQ_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ tpl .Values.rabbitmq.external.secrets.password.name . }}
        key: {{ tpl .Values.rabbitmq.external.secrets.password.key . }}
  {{- end }}
  {{- if .Values.common.rabbitmq.connectionConfigFromEnvironment }}
  - name: XRAY_RABBITMQ_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "rabbitmq.passwordSecretName" .}}
        key: rabbitmq-password
  {{- end }}
  {{ if or .Values.database.secrets.password .Values.database.password .Values.postgresql.enabled }}
  - name: XRAY_POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
  {{- if .Values.database.secrets.password }}
        name: {{ tpl .Values.database.secrets.password.name . }}
        key: {{ tpl .Values.database.secrets.password.key . }}
  {{- else if .Values.database.password }}
        {{- if not .Values.xray.unifiedSecretInstallation }}
        name: {{ template "xray.fullname" . }}-database-creds
        {{- else }}
        name: "{{ template "xray.fullname" . }}-unified-secret"
        {{- end }}
        key: db-password
  {{- else if .Values.postgresql.enabled }}
        name: {{ .Release.Name }}-postgresql
        key: password
  {{- end }}
  {{- end }}
  volumeMounts:
  - name: data-volume
    mountPath: {{ .Values.xray.persistence.mountPath | quote }}
  {{- if or (not .Values.xray.unifiedSecretInstallation) .Values.systemYamlOverride.existingSecret }}
  - name: systemyaml
  {{- else }}
  - name: {{ include "xray.unifiedCustomSecretVolumeName" . }}
  {{- end }}
    {{- if .Values.systemYamlOverride.existingSecret }}
    mountPath: "/tmp/etc/{{.Values.systemYamlOverride.dataKey}}"
    subPath: {{ .Values.systemYamlOverride.dataKey }}
    {{- else }}
    mountPath: "/tmp/etc/system.yaml"
    subPath: system.yaml
    {{- end }}
{{- if or .Values.xray.customCertificates.enabled .Values.global.customCertificates.enabled .Values.rabbitmq.auth.tls.enabled .Values.global.rabbitmq.auth.tls.enabled }}
- name: copy-custom-certificates
  image: {{ include "xray.getImageInfoByValue" (list . "initContainers") }}
  imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  {{- if .Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit .Values.containerSecurityContext "enabled" | toYaml) . | nindent 4 }}
  {{- end }}
  resources:
{{ toYaml .Values.initContainers.resources | indent 4 }}
  command:
  - 'bash'
  - '-c'
  - >
{{ include "xray.copyCustomCerts" . | indent 4 }}
{{ include "xray.copyRabbitmqCustomCerts" . | indent 4 }}
  volumeMounts:
    - name: data-volume
      mountPath: {{ .Values.xray.persistence.mountPath }}
    {{- if or .Values.xray.customCertificates.enabled .Values.global.customCertificates.enabled }}
    - name: ca-certs
      mountPath: "/tmp/certs"
    {{- end }}
    {{- if or .Values.global.rabbitmq.auth.tls.enabled .Values.rabbitmq.auth.tls.enabled }}
    - name: rabbitmq-ca-certs
      mountPath: "/tmp/rabbitmqcerts"
    {{- end }}
{{- end }}
{{- if .Values.waitForDatabase }}
{{- if .Values.postgresql.enabled }}
- name: "wait-for-db"
  image: {{ include "xray.getImageInfoByValue" (list . "initContainers") }}
  imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  {{- if .Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit .Values.containerSecurityContext "enabled" | toYaml) . | nindent 4 }}
  {{- end }}
  resources:
{{ toYaml .Values.initContainers.resources | indent 4 }}
  command:
  - 'bash'
  - '-c'
  - |
    echo "Waiting for postgresql to come up"
    ready=false;
    while ! $ready; do echo waiting;
      timeout 2s bash -c "</dev/tcp/{{ .Release.Name }}-postgresql/{{ .Values.postgresql.primary.service.ports.postgresql }}"; exit_status=$?;
      if [[ $exit_status -eq 0 ]]; then ready=true; echo "database ok"; fi; sleep 1; 
    done
{{- end }}
{{- end }}
{{- if and .Values.global.xray.rabbitmq.haQuorum.enabled .Values.common.rabbitmq.waitForReplicasQuorumOnStartup }}
- name: "wait-for-rabbitmq-replicas-quorum"
  image: {{ include "xray.getImageInfoByValue" (list . "initContainers") }}
  imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  {{- if .Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit .Values.containerSecurityContext "enabled" | toYaml) . | nindent 4 }}
  {{- end }}
  resources:
{{ toYaml .Values.initContainers.resources | indent 4 }}
  command:
  - 'bash'
  - '-c'
  - -ecx
  - |
    echo "Waiting for rabbitmq replicas quorum to be running"
    ready=false;
    amqpPort={{ .Values.rabbitmq.service.ports.amqp }}
    amqpTlsPort={{ .Values.rabbitmq.service.ports.amqpTls }}
    managerPort={{ .Values.rabbitmq.service.ports.manager }}
    managerSchema="http"
    additionalFlags=""
    if [[ "$JF_SHARED_RABBITMQ_MANAGEMENT_LISTENER_TLS_ENABLED" = "true" ]]; then
      managerSchema="https"
      additionalFlags="--insecure"
    fi
    rabbitMqManagementUrl=$(echo $JF_SHARED_RABBITMQ_URL | sed -e "s/amqp:/${managerSchema}:/" -e "s/amqps:/${managerSchema}:/" -e "s/:${amqpPort}/:${managerPort}/" -e "s/:${amqpTlsPort}/:${managerPort}/")
    while ! $ready; do echo waiting;
      # This would be better done with jq instead of grep -o
      # jq 'map(select ( .running == true )) | length')
      # but currently we do not have jq in the UBI-minimal base image approved by the installer team
      nodesNum=$(curl -s ${additionalFlags} -u${JF_SHARED_RABBITMQ_USERNAME}:${JF_SHARED_RABBITMQ_PASSWORD} ${rabbitMqManagementUrl}api/nodes | grep -o '"running"\s*:true' | wc -l | tr -d '[:space:]')
      echo $nodesNum
      quorumSize=$(( $JF_SHARED_RABBITMQ_REPLICASCOUNT/2 + 1 ))
      echo $quorumSize
      if [[ "$nodesNum" -ge "$quorumSize" ]]; then ready=true; echo "rabbitmq ok"; fi; sleep 5; 
    done
  env:
{{- if eq (include "xray.rabbitmq.isManagementListenerTlsEnabled" .) "true" }}
  - name: JF_SHARED_RABBITMQ_MANAGEMENT_LISTENER_TLS_ENABLED
    value: {{ include "xray.rabbitmq.isManagementListenerTlsEnabled" . | quote }}
{{- end }}
{{- if and .Values.rabbitmq.external.secrets (not .Values.common.rabbitmq.connectionConfigFromEnvironment) }}
  - name: JF_SHARED_RABBITMQ_USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ tpl .Values.rabbitmq.external.secrets.username.name . }}
        key: {{ tpl .Values.rabbitmq.external.secrets.username.key . }}
  - name: JF_SHARED_RABBITMQ_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ tpl .Values.rabbitmq.external.secrets.password.name . }}
        key: {{ tpl .Values.rabbitmq.external.secrets.password.key . }}
  - name: JF_SHARED_RABBITMQ_URL
    valueFrom:
      secretKeyRef:
        name: {{ tpl .Values.rabbitmq.external.secrets.url.name . }}
        key: {{ tpl .Values.rabbitmq.external.secrets.url.key . }}
{{- end }}
{{- if and (not .Values.rabbitmq.external.secrets) (not .Values.common.rabbitmq.connectionConfigFromEnvironment) (not .Values.common.rabbitmq.enabled) }}
  - name: JF_SHARED_RABBITMQ_USERNAME
    value: "{{ .Values.rabbitmq.external.username }}"
  - name: JF_SHARED_RABBITMQ_URL
    value: "{{ tpl .Values.rabbitmq.external.url . }}"
  - name: JF_SHARED_RABBITMQ_PASSWORD
    value: "{{ .Values.rabbitmq.external.password }}"
{{- end }}
{{- if .Values.common.rabbitmq.connectionConfigFromEnvironment }}
  - name: JF_SHARED_RABBITMQ_USERNAME
    value: {{ include "rabbitmq.user" .}}
  - name: JF_SHARED_RABBITMQ_URL
    value: {{ include "rabbitmq.url" .}}
  - name: JF_SHARED_RABBITMQ_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "rabbitmq.passwordSecretName" .}}
        key: rabbitmq-password
{{- end }}
  - name: JF_SHARED_RABBITMQ_REPLICASCOUNT
{{- if .Values.rabbitmq.enabled }}  
    value: "{{ .Values.rabbitmq.replicaCount }}"
{{- else }}
    value: "{{ .Values.global.xray.rabbitmq.replicaCount }}"
{{- end }}
{{- end }}
{{- if or .Values.common.customInitContainers .Values.global.customInitContainers }}
{{ tpl (include "xray.customInitContainers" .) . }}
{{- end }}
{{- if .Values.hostAliases }}
hostAliases:
{{ toYaml .Values.hostAliases }}
{{- end }}
{{- end -}}

{{/*
Common router container for the pods
*/}}
{{- define "xray.routerContainer" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
- name: {{ $dot.Values.router.name }}
  image: {{ include "xray.getImageInfoByValue" (list $dot "router") }}
  imagePullPolicy: {{ $dot.Values.router.image.imagePullPolicy }}
  {{- if $dot.Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit $dot.Values.containerSecurityContext "enabled" | toYaml) $dot | nindent 4 }}
  {{- end }}
  command:
    - '/bin/sh'
    - '-c'
    - >
    {{- with $dot.Values.common.preStartCommand }}
      echo "Running custom common preStartCommand command";
      {{ tpl . $ }};
    {{- end }}
      exec /opt/jfrog/router/app/bin/entrypoint-router.sh;
  {{- with $dot.Values.router.lifecycle }}
  lifecycle:
{{ toYaml . | indent 4 }}
  {{- end }}
  env:
  - name: JF_ROUTER_TOPOLOGY_LOCAL_REQUIREDSERVICETYPES
{{- if eq $indexReference "indexer" }}
    value: "jfxidx"
{{- else if eq $indexReference "persist" }}
    value: "jfxpst"
{{- else if eq $indexReference "analysis" }}
    value: "jfxana"
{{- else if eq $indexReference "sbom" }}
    value: "jfxsbm"
{{- else if eq $indexReference "policyenforcer" }}
    value: "jfxpe"
{{- else if eq $indexReference "server" }}
    value: "jfxr,jfob"
{{- else if eq $indexReference "panoramic" }}
    value: ""
{{- end }}
  {{- if $dot.Values.router.extraEnvVars }}
  {{- tpl $dot.Values.router.extraEnvVars . | nindent 2 }}
  {{- end }}
  ports:
    - name: http-router
      containerPort: {{ $dot.Values.router.internalPort }}
  volumeMounts:
  - name: data-volume
    mountPath: {{ $dot.Values.router.persistence.mountPath | quote }}
{{- if or $dot.Values.common.customVolumeMounts $dot.Values.global.customVolumeMounts }}
{{ tpl (include "xray.customVolumeMounts" $dot) $dot | indent 2 }}
{{- end }}
{{- with $dot.Values.router.customVolumeMounts }}
{{ tpl . $ | indent 2 }}
{{- end }}
  resources:
{{ toYaml $dot.Values.router.resources | indent 4 }}
{{- if $dot.Values.router.livenessProbe.enabled }}
  livenessProbe:
{{ tpl $dot.Values.router.livenessProbe.config $dot | indent 4 }}
{{- end }}
{{- if $dot.Values.router.readinessProbe.enabled }}
  readinessProbe:
{{ tpl $dot.Values.router.readinessProbe.config $dot | indent 4 }}
{{- end }}
{{- end -}}

{{/*
Common observability container for the pods
*/}}
{{- define "xray.observabilityContainer" -}}
- name: {{ .Values.observability.name }}
  image: {{ include "xray.getImageInfoByValue" (list . "observability") }}
  imagePullPolicy: {{ .Values.observability.image.imagePullPolicy }}
{{- if .Values.containerSecurityContext.enabled }}
  securityContext: {{- tpl (omit .Values.containerSecurityContext "enabled" | toYaml) . | nindent 4 }}
{{- end }}
  command:
    - '/bin/sh'
    - '-c'
    - >
      {{- with .Values.common.preStartCommand }}
        echo "Running custom common preStartCommand command";
        {{ tpl . $ }};
      {{- end }}
        exec /opt/jfrog/observability/app/bin/entrypoint-observability.sh;
  {{- with .Values.observability.lifecycle }}
  lifecycle:
{{ toYaml . | indent 4 }}
  {{- end }}
  env:
{{- if .Values.observability.extraEnvVars }}
  {{- tpl .Values.observability.extraEnvVars . | nindent 2 }}
{{- end }}
  volumeMounts:
    - name: data-volume
      mountPath: "{{ .Values.observability.persistence.mountPath }}"
  resources:
{{ toYaml .Values.observability.resources | indent 4 }}
{{- if .Values.observability.startupProbe.enabled }}
  startupProbe:
{{ tpl .Values.observability.startupProbe.config . | indent 4 }}
{{- end }}
{{- if .Values.observability.livenessProbe.enabled }}
  livenessProbe:
{{ tpl .Values.observability.livenessProbe.config . | indent 4 }}
{{- end }}
{{- end -}}

{{/*
Resolve xray server requiredServiceTypes value
*/}}
{{- define "xray.router.server.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxr,jfob" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray analysis requiredServiceTypes value
*/}}
{{- define "xray.router.analysis.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxana" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray persist requiredServiceTypes value
*/}}
{{- define "xray.router.persist.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxpst" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray policyenforcer requiredServiceTypes value
*/}}
{{- define "xray.router.policyenforcer.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxpe" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray indexer requiredServiceTypes value
*/}}
{{- define "xray.router.indexer.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxidx" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve xray sbom requiredServiceTypes value
*/}}
{{- define "xray.router.sbom.requiredServiceTypes" -}}
{{- $requiredTypes := "jfxsbm" -}}
{{- $requiredTypes -}}
{{- end -}}

{{/*
Resolve autoscalingQueues value for indexer
*/}}
{{- define "xray.autoscalingQueuesIndexer" -}}
{{- if .Values.indexer.autoscaling.keda.queues }}
{{- range .Values.indexer.autoscaling.keda.queues }}
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
Resolve autoscalingQueues value for persist
*/}}
{{- define "xray.autoscalingQueuesPersist" -}}
{{- if .Values.persist.autoscaling.keda.queues }}
{{- range .Values.persist.autoscaling.keda.queues }}
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
Resolve autoscalingQueues value for analysis
*/}}
{{- define "xray.autoscalingQueuesAnalysis" -}}
{{- if .Values.analysis.autoscaling.keda.queues }}
{{- range .Values.analysis.autoscaling.keda.queues }}
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
Resolve autoscalingQueues value for sbom
*/}}
{{- define "xray.autoscalingQueuesSbom" -}}
{{- if .Values.sbom.autoscaling.keda.queues }}
{{- range .Values.sbom.autoscaling.keda.queues }}
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
Resolve autoscalingQueues value for panoramic
*/}}
{{- define "xray.autoscalingQueuesPanoramic" -}}
{{- if .Values.panoramic.autoscaling.keda.queues }}
{{- range .Values.panoramic.autoscaling.keda.queues }}
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
Resolve autoscalingQueues value for policyenforcer
*/}}
{{- define "xray.autoscalingQueuesPolicyenforcer" -}}
{{- if .Values.policyenforcer.autoscaling.keda.queues }}
{{- range .Values.policyenforcer.autoscaling.keda.queues }}
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
{{- if .Values.server.autoscaling.keda.queues }}
{{- range .Values.server.autoscaling.keda.queues }}
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
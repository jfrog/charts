{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "jfrog-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jfrog-platform.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jfrog-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jfrog-platform.labels" -}}
helm.sh/chart: {{ include "jfrog-platform.chart" . }}
{{ include "jfrog-platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "jfrog-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jfrog-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "jfrog-platform.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "jfrog-platform.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Custom init container for Postgres setup
*/}}
{{- define "initdb" -}}
{{- if and .Values.global.database.initDBCreation (ne .Chart.Name "pdn-server") }}
- name: postgres-setup-init
  image: {{ .Values.global.database.initContainerSetupDBImage }}
  imagePullPolicy: {{ .Values.global.database.initContainerImagePullPolicy }}
  {{- with .Values.global.database.initContainerSetupDBUser }}
  securityContext:
    runAsUser: {{ . }}
  {{- end }}
  command:
    - '/bin/bash'
    - '-c'
    - >
      {{- if (ne .Chart.Name "artifactory") }}
      until nc -z -w 5 {{ .Release.Name }}-artifactory 8082; do echo "Waiting for artifactory to start"; sleep 10; done;
      {{- end }}
      echo "Running init db scripts";
      bash /scripts/setupPostgres.sh
  {{- if eq .Chart.Name "pipelines" }}
  env:
    - name: PGUSERNAME
    {{- if .Values.global.database.secrets.adminUsername }}
      valueFrom:
        secretKeyRef:
          name: {{ tpl .Values.global.database.secrets.adminUsername.name . }}
          key: {{ tpl .Values.global.database.secrets.adminUsername.key . }}
    {{- else if .Values.global.database.adminUsername }}
      value: {{ .Values.global.database.adminUsername }}
    {{- end }}
    - name: DB_HOST
      value: {{ tpl .Values.global.database.host . }}
    - name: DB_PORT
      value: {{ .Values.global.database.port | quote }}
    - name: DB_SSL_MODE
      value: {{ .Values.global.database.sslMode | quote }}
    - name: DB_NAME
      value: {{ .Values.global.postgresql.database }}
    - name: DB_USERNAME
      value: {{ .Values.global.postgresql.user }}
    - name: DB_PASSWORD
      value: {{ .Values.global.postgresql.password }}
    - name: PGPASSWORD
    {{- if .Values.global.database.secrets.adminPassword }}
      valueFrom:
        secretKeyRef:
          name: {{ tpl .Values.global.database.secrets.adminPassword.name . }}
          key: {{ tpl .Values.global.database.secrets.adminPassword.key . }}
    {{- else if .Values.global.database.adminPassword }}
      value: {{ .Values.global.database.adminPassword }}
    {{- end }}
    - name: CHART_NAME
      value: {{ .Chart.Name }}
  {{- else }}
  env:
    - name: PGUSERNAME
    {{- if .Values.global.database.secrets.adminUsername }}
      valueFrom:
        secretKeyRef:
          name: {{ tpl .Values.global.database.secrets.adminUsername.name . }}
          key: {{ tpl .Values.global.database.secrets.adminUsername.key . }}
    {{- else if .Values.global.database.adminUsername }}
      value: {{ .Values.global.database.adminUsername }}
    {{- end }}
    - name: DB_HOST
      value: {{ tpl .Values.global.database.host . }}
    - name: DB_PORT
      value: {{ .Values.global.database.port | quote }}
    - name: DB_SSL_MODE
      value: {{ .Values.global.database.sslMode | quote }}
    - name: DB_NAME
      value: {{ include "database.name" . }}
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
    {{- if .Values.database.secrets.user }}
          name: {{ tpl .Values.database.secrets.user.name . }}
          key: {{ tpl .Values.database.secrets.user.key . }}
    {{- else if .Values.database.user }}
    {{- $chartFullName := printf "%s.fullname" .Chart.Name }}
          name: {{ include $chartFullName . }}-database-creds
          key: db-user
    {{- end }}
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
    {{- if .Values.database.secrets.password }}
          name: {{ tpl .Values.database.secrets.password.name . }}
          key: {{ tpl .Values.database.secrets.password.key . }}
    {{- else if .Values.database.password }}
    {{- $chartFullName := printf "%s.fullname" .Chart.Name }}
          name: {{ include $chartFullName . }}-database-creds
          key: db-password
    {{- end }}
    - name: PGPASSWORD
    {{- if .Values.global.database.secrets.adminPassword }}
      valueFrom:
        secretKeyRef:
          name: {{ tpl .Values.global.database.secrets.adminPassword.name . }}
          key: {{ tpl .Values.global.database.secrets.adminPassword.key . }}
    {{- else if .Values.global.database.adminPassword }}
      value: {{ .Values.global.database.adminPassword }}
    {{- end }}
    - name: CHART_NAME
      value: {{ .Chart.Name }}
  {{- end }}
  volumeMounts:
    - name: postgres-setup-init-vol
      mountPath: "/scripts"
{{- end }}
{{- end }}

{{/*
Custom volume for Postgres setup
*/}}
{{- define "initdb-volume" -}}
{{- if .Values.global.database.initDBCreation }}
- name: postgres-setup-init-vol
  configMap:
    name: {{ .Release.Name }}-setup-script
{{- end }}
{{- end }}

{{/*
NOTE: This utility template is needed until https://git.io/JvuGN is resolved.
Call a template from the context of a subchart.
Usage:
  {{ include "call-nested" (list . "<subchart_name>" "<subchart_template_name>") }}
*/}}
{{- define "call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values = index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{/*
Define database url
*/}}
{{- define "database.url" -}}
{{- if eq .Chart.Name "xray" -}}
{{- printf "%s://%s:%g/%s?sslmode=%s" "postgres" (tpl .Values.global.database.host .) .Values.global.database.port (.Chart.Name | replace "-" "_") .Values.global.database.sslMode -}}
{{- else -}}
{{- printf "%s://%s:%g/%s?sslmode=%s" "jdbc:postgresql" (tpl .Values.global.database.host .) .Values.global.database.port (.Chart.Name | replace "-" "_") .Values.global.database.sslMode -}}
{{- end -}}
{{- end -}}

{{/*
Define database name
*/}}
{{- define "database.name" -}}
{{- printf "%s" (.Chart.Name | replace "-" "_") -}}
{{- end }}

{{/*
Resolve jfrog url
*/}}
{{- define "jfrog-platform.jfrogUrl" -}}
{{- printf "http://%s-artifactory:8082" .Release.Name -}}
{{- end -}}

{{/*
Expand the name of rabbit chart.
*/}}
{{- define "rabbitmq.name" -}}
{{- default (printf "%s" "rabbitmq") .Values.rabbitmq.nameOverride -}}
{{- end -}}


{{- define "jfrog-platform.rabbitmq.migration.fullname" -}}
{{- $name := default "rabbitmq-migration" -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for rabbitmq migration
*/}}
{{- define "jfrog-platform.rabbitmq.migration.serviceAccountName" -}}
{{- if .Values.rabbitmq.migration.serviceAccount.create -}}
{{ default (include "jfrog-platform.rabbitmq.migration.fullname" .) .Values.rabbitmq.migration.serviceAccount.name }}
{{- else -}}
{{ default "rabbitmq-migration" .Values.rabbitmq.migration.serviceAccount.name }}
{{- end -}}
{{- end -}}
{{- if .Values.artifactory.systemYaml -}}
{{- tpl .Values.artifactory.systemYaml . -}}
{{- else -}}
{{ (tpl ( $.Files.Get "files/system.yaml" ) .) }}
{{- end -}}
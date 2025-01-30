{{- if .Values.systemYaml -}}
{{- tpl .Values.systemYaml . -}}
{{- else -}}
{{ (tpl ( $.Files.Get "files/system.yaml" ) .) }}
{{- end -}}

{{- if .Values.distribution.systemYaml -}}
{{- tpl .Values.distribution.systemYaml . -}}
{{- else -}}
{{ (tpl ( $.Files.Get "files/system.yaml" ) .) }}
{{- end -}}
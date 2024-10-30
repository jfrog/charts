{{- if .Values.xray.systemYaml -}}
{{- tpl .Values.xray.systemYaml . -}}
{{- else -}}
{{ (tpl ( $.Files.Get "files/system.yaml" ) .) }}
{{- end -}}
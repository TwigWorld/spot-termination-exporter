{{- define "spot-termination-exporter.configMapName" -}}
{{ template "spot-termination-exporter.fullname" . }}-{{ .Release.Revision }}
{{ end -}}
{{- define "spot-termination-exporter.secretName" -}}
{{ template "spot-termination-exporter.fullname" . }}-{{ .Release.Revision }}
{{ end -}}

{{- define "spot-termination-exporter.shortname" -}} 
{{- if .Values.fullnameOverride -}} 
{{- .Values.fullnameOverride | trunc 24 | trimSuffix "-" -}} 
{{- else -}} 
{{- $name := default .Chart.Name .Values.nameOverride -}} 
{{- if contains $name .Release.Name -}} 
{{- .Release.Name | trunc 24 | trimSuffix "-" -}} 
{{- else -}} 
{{- printf "%s-%s" .Release.Name $name | trunc 24 | trimSuffix "-" -}} 
{{- end -}} 
{{- end -}} 
{{- end -}} 


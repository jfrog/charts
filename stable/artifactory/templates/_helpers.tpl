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
Generate a self-signed TLS certificate. Used only when
.Values.nginx.generateSelfSignedCert=true AND no legacy Secret exists.
This is opt-in and disabled by default. It is intended for dev/test only —
production installs should supply their own certificate via nginx.tlsSecretName.
*/}}
{{- define "artifactory.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "artifactory.fullname" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "artifactory.fullname" .) .Release.Namespace ) -}}
{{- $ca := genCA "artifactory-ca" 365 -}}
{{- $cert := genSignedCert ( include "artifactory.fullname" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Resolve the TLS secret name to use for nginx HTTPS.
Priority:
  1. .Values.nginx.tlsSecretName (custom) — preferred
  2. Legacy in-cluster secret <fullname>-nginx-certificate — upgrade-safety fallback
  3. Chart-generated Secret when .Values.nginx.generateSelfSignedCert=true (opt-in, dev/test)
  4. Empty string — no cert available
*/}}
{{- define "nginx.tlsSecretEffective" -}}
{{- if .Values.nginx.tlsSecretName -}}
{{- .Values.nginx.tlsSecretName -}}
{{- else -}}
{{- $legacyName := printf "%s-nginx-certificate" (include "artifactory.fullname" .) -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace $legacyName -}}
{{- if $existing -}}
{{- $legacyName -}}
{{- else if .Values.nginx.generateSelfSignedCert -}}
{{- $legacyName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
True (non-empty) only when HTTPS is requested AND a cert is actually available
(custom, legacy in-cluster, or chart-generated when opt-in flag is on).
Used to gate ssl_certificate directives, HTTPS listens, and 443 service ports.
*/}}
{{- define "nginx.httpsEffective" -}}
{{- if and .Values.nginx.https.enabled (include "nginx.tlsSecretEffective" .) -}}
true
{{- end -}}
{{- end -}}

{{/*
Fresh-install validation: HTTPS is enabled but no TLS secret path is available.
Returns "true" only when the install must be blocked. The install is allowed if:
  - nginx.tlsSecretName is set (custom cert), OR
  - nginx.generateSelfSignedCert=true (opt-in chart-generated cert), OR
  - nginx.https.enabled=false (HTTP only), OR
  - it's an upgrade (existing installs are exempt via the tlsSecretEffective lookup fallback).
*/}}
{{- define "nginx.tlsCertMissingOnInstall" -}}
{{- if and .Release.IsInstall .Values.nginx.enabled .Values.nginx.https.enabled (not .Values.nginx.tlsSecretName) (not .Values.nginx.generateSelfSignedCert) -}}
true
{{- end -}}
{{- end -}}

{{/*
Rich, joinKey/masterKey-style error message rendered when nginx HTTPS is on
but no TLS secret was provided AND self-signed generation is not enabled.
*/}}
{{- define "nginx.tlsCertValidationFailMessage" -}}
{{- print "\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print " 🛑  ERROR: MISSING NGINX TLS CERTIFICATE (Artifactory)\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "nginx.https.enabled=true but nginx.tlsSecretName is not set,\n" -}}
{{- print "and nginx.generateSelfSignedCert is not enabled.\n" -}}
{{- print "By default this chart does NOT generate TLS certificates.\n\n" -}}
{{- print "👉 OPTION 1 (Production Recommended): SUPPLY YOUR OWN CERTIFICATE\n" -}}
{{- print "      Create a kubernetes.io/tls secret:\n" -}}
{{- printf "      kubectl create secret tls artifactory-nginx-tls -n %s \\\n" .Release.Namespace -}}
{{- print "        --cert=./tls.crt --key=./tls.key\n" -}}
{{- print "      Reference the secret name in helm values:\n" -}}
{{- print "      --set nginx.tlsSecretName=artifactory-nginx-tls\n\n" -}}
{{- print "👉 OPTION 2 (Dev/Test only): OPT IN TO A SELF-SIGNED CERTIFICATE\n" -}}
{{- print "      Enable chart-side generation in helm values:\n" -}}
{{- print "      --set nginx.generateSelfSignedCert=true\n" -}}
{{- print "      WARNING: The chart-generated key is unique per install but is not\n" -}}
{{- print "               issued by a trusted CA. Do not use in production.\n\n" -}}
{{- print "👉 OPTION 3: DISABLE HTTPS (HTTP only)\n" -}}
{{- print "      Disable HTTPS in helm values:\n" -}}
{{- print "      --set nginx.https.enabled=false\n\n" -}}
{{- print "📚 TO LEARN MORE:\n" -}}
{{- print "    https://docs.jfrog.com/installation/docs/establish-tls-in-artifactory-and-jfrog-platform\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "\n" -}}
{{- end -}}

{{/*
Scheme (http/https) based on Access or Router TLS enabled/disabled
*/}}
{{- define "artifactory.scheme" -}}
{{- if or .Values.access.accessConfig.security.tls .Values.router.tlsEnabled -}}
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
Return the proper artifactory chart image names, with support for digest
*/}}
{{- define "artifactory.getImageInfoByValue" -}}
{{- $dot := index . 0 }}
{{- $indexReference := index . 1 }}
{{- $image := index $dot.Values $indexReference "image" }}
{{- $registryName := index $dot.Values $indexReference "image" "registry" -}}
{{- $repositoryName := index $dot.Values $indexReference "image" "repository" -}}
{{- $digest := "" -}}
{{- $tag := "" -}}
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
    {{- if and $dot.Values.global.versions.artifactory (or (eq $indexReference "artifactory") (eq $indexReference "nginx") ) }}
    {{- $tag = $dot.Values.global.versions.artifactory | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.artifactory (eq $indexReference "artifactory") }}
    {{- $digest = $dot.Values.global.digests.artifactory | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.nginx (eq $indexReference "nginx") }}
    {{- $digest = $dot.Values.global.digests.nginx | toString -}}
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
    {{- if and $dot.Values.global.versions.jfmelt (eq $indexReference "jfmelt") }}
    {{- $tag = $dot.Values.global.versions.jfmelt | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.jfmelt (eq $indexReference "jfmelt") }}
    {{- $digest = $dot.Values.global.digests.jfmelt | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.unifiedpolicy (eq $indexReference "unifiedpolicy") }}
    {{- $tag = $dot.Values.global.versions.unifiedpolicy | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.unifiedpolicy (eq $indexReference "unifiedpolicy") }}
    {{- $digest = $dot.Values.global.digests.unifiedpolicy | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.evaluation (eq $indexReference "evaluation") }}
    {{- $tag = $dot.Values.global.versions.evaluation | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.evaluation (eq $indexReference "evaluation") }}
    {{- $digest = $dot.Values.global.digests.evaluation | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.observability (eq $indexReference "observability") }}
    {{- $tag = $dot.Values.global.versions.observability | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.observability (eq $indexReference "observability") }}
    {{- $digest = $dot.Values.global.digests.observability | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.frontend (eq $indexReference "frontend") }}
    {{- $tag = $dot.Values.global.versions.frontend | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.frontend (eq $indexReference "frontend") }}
    {{- $digest = $dot.Values.global.digests.frontend | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.filebeat (eq $indexReference "filebeat") }}
    {{- $tag = $dot.Values.global.versions.filebeat | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.filebeat (eq $indexReference "filebeat") }}
    {{- $digest = $dot.Values.global.digests.filebeat | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.versions.platformfederation (eq $indexReference "platformfederation") }}
    {{- $tag = $dot.Values.global.versions.platformfederation | toString -}}
    {{- end -}}
    {{- if and $dot.Values.global.digests.platformfederation (eq $indexReference "platformfederation") }}
    {{- $digest = $dot.Values.global.digests.platformfederation | toString -}}
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
{{- define "artifactory.application.version" -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}

{{/*
Return the proper artifactory app version
*/}}
{{- define "artifactory.app.version" -}}
{{- $tag := (splitList ":" ((include "artifactory.getImageInfoByValue" (list . "artifactory" )))) | last | toString -}}
{{- printf "%s" $tag -}}
{{- end -}}

{{/*
Custom certificate copy command for jfbus
*/}}
{{- define "jfbus.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.jfbus.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.jfbus.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.jfbus.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.jfbus.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.jfbus.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.jfbus.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
Custom certificate copy command for rtfs
*/}}
{{- define "rtfs.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.rtfs.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.rtfs.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.rtfs.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.rtfs.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.rtfs.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.rtfs.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
Custom certificate copy command for artifactory
*/}}
{{- define "artifactory.copyCustomCerts" -}}
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
{{- define "artifactory.router.requiredServiceTypes" -}}
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
{{- if and .Values.frontend.enabled (not .Values.frontend.asPod) -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jffe" -}}
{{- end -}}
{{- if .Values.jfconnect.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfcon" -}}
{{- end -}}
{{- if .Values.jfconfig.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfcfg" -}}
{{- end -}}
{{- if .Values.evidence.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jfevd" -}}
{{- end -}}
{{- if .Values.topology.enabled -}}
  {{- $requiredTypes = printf "%s,%s" $requiredTypes "jftpl" -}}
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
{{- else if include "nginx.httpsEffective" . -}}
{{- printf "%s" "https" -}}
{{- else -}}
{{- printf "%s" "http" -}}
{{- end -}}
{{- end -}}

{{/*
Check usage of curl --haproxy-protocol flag
*/}}
{{- define "curl.haproxyprotocol" -}}
{{ if or (and .Values.nginx.http.enabled .Values.nginx.httpUseProxyProtocol) (and (not .Values.nginx.http.enabled) .Values.nginx.httpsUseProxyProtocol) }}
{{- printf "%s" "--haproxy-protocol" -}}
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
{{- else if include "nginx.httpsEffective" . -}}
{{- .Values.nginx.https.internalPort -}}
{{- else -}}
{{- .Values.nginx.http.internalPort -}}
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
Resolve Artifactory pod node selector value
*/}}
{{- define "artifactory.nodeSelector" -}}
nodeSelector:
{{- if .Values.global.nodeSelector }}
{{ toYaml .Values.global.nodeSelector | indent 2 }}
{{- else if .Values.artifactory.nodeSelector }}
{{ toYaml .Values.artifactory.nodeSelector | indent 2 }}
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
Resolve unifiedCustomSecretVolumeName value
*/}}
{{- define "artifactory.unifiedCustomSecretVolumeName" -}}
{{- printf "%s-%s" (include "artifactory.name" .) ("unified-secret-volume") | trunc 63 -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.
*/}}
{{- define "artifactory.checkDuplicateUnifiedCustomVolume" -}}
{{- if or .Values.global.customVolumes .Values.artifactory.customVolumes -}}
{{- $val := (tpl (include "artifactory.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
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
Resolve unified secret prepend release name
*/}}
{{- define "artifactory.unifiedSecretPrependReleaseName" -}}
{{- if .Values.artifactory.unifiedSecretPrependReleaseName }}
{{- printf "%s" (include "artifactory.fullname" .) -}}
{{- else }}
{{- printf "%s" (include "artifactory.name" .) -}}
{{- end }}
{{- end }}

{{/*
Resolve Service prepend release name
*/}}
{{- define "artifactory.servicePrependReleaseName" -}}
{{- if .Values.artifactory.servicePrependReleaseName }}
{{- printf "%s" (include "artifactory.fullname" .) -}}
{{- else }}
{{- printf "%s" (include "artifactory.name" .) -}}
{{- end }}
{{- end }}

{{/*
Resolve artifactory metrics
*/}}
{{- define "artifactory.metrics" -}}
{{- if .Values.artifactory.openMetrics -}} 
{{- if .Values.artifactory.openMetrics.enabled -}}
{{ include "metrics.enabled" . }}
{{- end -}}
{{- else if .Values.artifactory.metrics -}}
{{- if .Values.artifactory.metrics.enabled -}}
{{ include "metrics.enabled" . }}
{{- end -}}
{{- end -}}
{{- end -}}

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
{{- printf "%s-%s" (include "artifactory.fullname" .) .Values.ingressGrpc.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified grpc service name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "artifactory.serviceGrpc.fullname" -}}
{{- printf "%s-%s" (include "artifactory.fullname" .) .Values.artifactory.serviceGrpc.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "rtfs.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.rtfs.name -}}
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
Resolve customVolumes value
*/}}
{{- define "artifactory.rtfs.customVolumes" -}}
{{- if .Values.rtfs.customVolumes -}}
{{- .Values.rtfs.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.rtfs.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.rtfs.customVolumes -}}
{{- $val := (tpl (include "artifactory.rtfs.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
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
    Resolve jfrogUrl value
*/}}
{{- define "rtfs.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.rtfs.jfrogUrl -}}
{{- .Values.rtfs.jfrogUrl -}}
{{- else -}}
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
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
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.apptrust.name -}}
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
Resolve customVolumes value
*/}}
{{- define "artifactory.apptrust.customVolumes" -}}
{{- if .Values.apptrust.customVolumes -}}
{{- .Values.apptrust.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
AppTrust command
*/}}
{{- define "apptrust.command" -}}
{{- if .Values.apptrust.customCommand }}
{{  toYaml .Values.apptrust.customCommand }}
{{- end }}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.apptrust.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.apptrust.customVolumes -}}
{{- $val := (tpl (include "artifactory.apptrust.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
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
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
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
Resolve AppTrust customSidecarContainers value
*/}}
{{- define "artifactory.apptrust.customSidecarContainers" -}}
{{- if .Values.apptrust.customSidecarContainers -}}
{{- .Values.apptrust.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve AppTrust customInitContainers value
*/}}
{{- define "artifactory.apptrust.customInitContainers" -}}
{{- if .Values.apptrust.customInitContainers -}}
{{- .Values.apptrust.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve AppTrust autoscalling metrics
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
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.unifiedpolicy.name -}}
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
Resolve customVolumes value
*/}}
{{- define "artifactory.unifiedpolicy.customVolumes" -}}
{{- if .Values.unifiedpolicy.customVolumes -}}
{{- .Values.unifiedpolicy.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.unifiedpolicy.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.unifiedpolicy.customVolumes -}}
{{- $val := (tpl (include "artifactory.unifiedpolicy.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
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
    Resolve jfrogUrl value
*/}}
{{- define "unifiedpolicy.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.unifiedpolicy.jfrogUrl -}}
{{- .Values.unifiedpolicy.jfrogUrl -}}
{{- else -}}
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
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
Resolve unifiedpolicy autoscalling metrics
*/}}
{{- define "unifiedpolicy.metrics" -}}
{{- if .Values.unifiedpolicy.autoscaling.metrics -}}
{{- .Values.unifiedpolicy.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for evaluation-service.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "evaluation.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.evaluation.name -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.evaluation.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.evaluation.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumes value
*/}}
{{- define "artifactory.evaluation.customVolumes" -}}
{{- if .Values.evaluation.customVolumes -}}
{{- .Values.evaluation.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.evaluation.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.evaluation.customVolumes -}}
{{- $val := (tpl (include "artifactory.evaluation.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
evaluation command
*/}}
{{- define "evaluation.command" -}}
{{- if .Values.evaluation.customCommand }}
{{  toYaml .Values.evaluation.customCommand }}
{{- end }}
{{- end -}}

{{/*
    Resolve jfrogUrl value
*/}}
{{- define "evaluation.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.evaluation.jfrogUrl -}}
{{- .Values.evaluation.jfrogUrl -}}
{{- else -}}
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts evaluation value
*/}}
{{- define "artifactory.evaluation.customVolumeMounts" -}}
{{- if .Values.evaluation.customVolumeMounts -}}
{{- .Values.evaluation.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve evaluation customSidecarContainers value
*/}}
{{- define "artifactory.evaluation.customSidecarContainers" -}}
{{- if .Values.evaluation.customSidecarContainers -}}
{{- .Values.evaluation.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve evaluation customInitContainers value
*/}}
{{- define "artifactory.evaluation.customInitContainers" -}}
{{- if .Values.evaluation.customInitContainers -}}
{{- .Values.evaluation.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve evaluation autoscalling metrics
*/}}
{{- define "evaluation.metrics" -}}
{{- if .Values.evaluation.autoscaling.metrics -}}
{{- .Values.evaluation.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Return true if both AWS S3 V3 identitySecret and credentialSecret are configured with non-empty values
*/}}
{{- define "artifactory.awsS3V3SecretsConfigured" -}}
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
{{- define "artifactory.azureBlobSecretsConfigured" -}}
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
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.jfbus.name -}}
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
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.jfbus.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.jfbus.customVolumes -}}
{{- $val := (tpl (include "artifactory.jfbus.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
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
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts jfbus value
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


{{/* JFMelt */}}

{{/*
True when jfconnect is supported (Pro) and enabled in values.
*/}}
{{- define "artifactory.jfconnect.supported" -}}
{{- if and .Values.jfconnect.enabled (not (regexMatch "^.*(oss|cpp-ce|jcr).*$" .Values.artifactory.image.repository)) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
jfmelt is only deployed when enabled, both jfbus and jfconnect are available, and a database is configured.
jfmelt requires a database to start; without one (no bundled postgresql and no external database) it must not be deployed.
*/}}
{{- define "artifactory.jfmelt.enabled" -}}
{{- if and .Values.jfmelt.enabled .Values.jfbus.enabled (eq (include "artifactory.jfconnect.supported" .) "true") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified JFmelt name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "jfmelt.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.jfmelt.name -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.jfmelt.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.jfmelt.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Custom certificate copy command for jfmelt
*/}}
{{- define "jfmelt.copyCustomCerts" -}}
echo "Copy custom certificates to {{ .Values.jfmelt.persistence.mountPath }}/etc/security/keys/trusted";
mkdir -p {{ .Values.jfmelt.persistence.mountPath }}/etc/security/keys/trusted;
for file in $(ls -1 /tmp/certs/* | grep -v .key | grep -v ":" | grep -v grep); do if [ -f "${file}" ]; then cp -v ${file} {{ .Values.jfmelt.persistence.mountPath }}/etc/security/keys/trusted; fi done;
if [ -f {{ .Values.jfmelt.persistence.mountPath }}/etc/security/keys/trusted/tls.crt ]; then mv -v {{ .Values.jfmelt.persistence.mountPath }}/etc/security/keys/trusted/tls.crt {{ .Values.jfmelt.persistence.mountPath }}/etc/security/keys/trusted/ca.crt; fi;
{{- end -}}

{{/*
Resolve JFmelt customVolumes value
*/}}
{{- define "artifactory.jfmelt.customVolumes" -}}
{{- if .Values.jfmelt.customVolumes -}}
{{- .Values.jfmelt.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.jfmelt.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.jfmelt.customVolumes -}}
{{- $val := (tpl (include "artifactory.jfmelt.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
JFmelt command
*/}}
{{- define "jfmelt.command" -}}
{{- if .Values.jfmelt.customCommand }}
{{ toYaml .Values.jfmelt.customCommand }}
{{- end }}
{{- end -}}

{{/*
Resolve jfrogUrl for JFmelt service
*/}}
{{- define "jfmelt.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfmelt.jfrogUrl -}}
{{- .Values.jfmelt.jfrogUrl -}}
{{- else -}}
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
{{- end -}}

{{/*
Resolve customVolumeMounts jfmelt value
*/}}
{{- define "artifactory.jfmelt.customVolumeMounts" -}}
{{- if .Values.jfmelt.customVolumeMounts -}}
{{- .Values.jfmelt.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFmelt customSidecarContainers value
*/}}
{{- define "artifactory.jfmelt.customSidecarContainers" -}}
{{- if .Values.jfmelt.customSidecarContainers -}}
{{- .Values.jfmelt.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFmelt customInitContainers value
*/}}
{{- define "artifactory.jfmelt.customInitContainers" -}}
{{- if .Values.jfmelt.customInitContainers -}}
{{- .Values.jfmelt.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve JFmelt autoscaling metrics
*/}}
{{- define "jfmelt.metrics" -}}
{{- if .Values.jfmelt.autoscaling.metrics -}}
{{- .Values.jfmelt.autoscaling.metrics -}}
{{- end -}}
{{- end -}}


{{/* PlatformFederation */}}
{{/*
Create a default fully qualified PlatformFederation name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "platformfederation.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.platformfederation.name -}}
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
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.platformfederation.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.platformfederation.customVolumes -}}
{{- $val := (tpl (include "artifactory.platformfederation.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
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
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
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

{{/*
#############################
## Frontend Pod Helpers
#############################
*/}}

{{/*
Create a default fully qualified app name for frontend.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "frontend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" (.Values.fullnameOverride | trunc 63 | trimSuffix "-") .Values.frontend.name -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") .Values.frontend.name -}}
{{- else -}}
{{- printf "%s-%s-%s" (.Release.Name | trunc 63 | trimSuffix "-") $name .Values.frontend.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve frontend customInitContainers value
*/}}
{{- define "artifactory.frontend.customInitContainers" -}}
{{- if .Values.frontend.customInitContainers -}}
{{- .Values.frontend.customInitContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve frontend customSidecarContainers value
*/}}
{{- define "artifactory.frontend.customSidecarContainers" -}}
{{- if .Values.frontend.customSidecarContainers -}}
{{- .Values.frontend.customSidecarContainers -}}
{{- end -}}
{{- end -}}

{{/*
Resolve frontend customVolumes value
*/}}
{{- define "artifactory.frontend.customVolumes" -}}
{{- if .Values.frontend.customVolumes -}}
{{- .Values.frontend.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Check the Duplication of volume names for secrets. If unifiedSecretInstallation is enabled then the method is checking for volume names,
if the volume exists in customVolume then an extra volume with the same name will not be getting added in unifiedSecretInstallation case.*/}}
{{- define "artifactory.frontend.checkDuplicateUnifiedCustomVolume" -}}
{{- if .Values.frontend.customVolumes -}}
{{- $val := (tpl (include "artifactory.frontend.customVolumes" .) .) | toJson -}}
{{- contains (include "artifactory.unifiedCustomSecretVolumeName" .) $val | toString -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve frontend customVolumeMounts value
*/}}
{{- define "artifactory.frontend.customVolumeMounts" -}}
{{- if .Values.frontend.customVolumeMounts -}}
{{- .Values.frontend.customVolumeMounts -}}
{{- end -}}
{{- end -}}

{{/*
Resolve frontend autoscaling metrics
*/}}
{{- define "frontend.metrics" -}}
{{- if .Values.frontend.autoscaling.metrics -}}
{{- .Values.frontend.autoscaling.metrics -}}
{{- end -}}
{{- end -}}

{{/*
Resolve jfrogUrl value
*/}}
{{- define "artifactory.jfrogUrl" -}}
{{- if .Values.global.jfrogUrl -}}
{{- .Values.global.jfrogUrl -}}
{{- else if .Values.jfrogUrl -}}
{{- .Values.jfrogUrl -}}
{{- else -}}
{{- printf "%s://%s:%v" (include "artifactory.scheme" .) (include "artifactory.fullname" .) .Values.artifactory.externalPort -}}
{{- end -}}
{{- end -}}

{{/*
Resolve observability customVolumes value
*/}}
{{- define "artifactory.observability.customVolumes" -}}
{{- if .Values.observability.customVolumes -}}
{{- .Values.observability.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Resolve router customVolumes value
*/}}
{{- define "artifactory.router.customVolumes" -}}
{{- if .Values.router.customVolumes -}}
{{- .Values.router.customVolumes -}}
{{- end -}}
{{- end -}}

{{/*
Returns "true" if join key is supplied via global/artifactory joinKey or *joinKeySecretName (non-empty).
*/}}
{{- define "artifactory.valuesJoinKeySourcePresent" -}}
{{- if or .Values.global.joinKey .Values.artifactory.joinKey .Values.global.joinKeySecretName .Values.artifactory.joinKeySecretName -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}

{{/*
Returns "true" if master key is supplied via global/artifactory masterKey or *masterKeySecretName (non-empty).
*/}}
{{- define "artifactory.valuesMasterKeySourcePresent" -}}
{{- if or .Values.global.masterKey .Values.artifactory.masterKey .Values.global.masterKeySecretName .Values.artifactory.masterKeySecretName -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}

{{/*
"true" if join key is resolvable from Helm values (global/artifactory joinKey or *joinKeySecretName).
*/}}
{{- define "artifactory.joinKeyResolvable" -}}
{{- include "artifactory.valuesJoinKeySourcePresent" . -}}
{{- end -}}

{{/*
"true" if master key is resolvable from Helm values (global/artifactory masterKey or *masterKeySecretName).
*/}}
{{- define "artifactory.masterKeyResolvable" -}}
{{- include "artifactory.valuesMasterKeySourcePresent" . -}}
{{- end -}}

{{/*
Single gate: "true" only if both join key and master key can be resolved.
*/}}
{{- define "artifactory.mandatoryKeysConfigurationValid" -}}
{{- if and (eq (include "artifactory.joinKeyResolvable" .) "true") (eq (include "artifactory.masterKeyResolvable" .) "true") -}}
{{- printf "true" -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}

{{/*
Multi-line error when keysPassedViaSystemyaml fails. Partial messages when only one key is missing; full message when both missing.
*/}}
{{- define "artifactory.mandatoryKeysValidationFailMessage" -}}
{{- $joinOk := eq (include "artifactory.joinKeyResolvable" .) "true" -}}
{{- $masterOk := eq (include "artifactory.masterKeyResolvable" .) "true" -}}
{{- print "\n********JFrog has introduced new services (e.g., JFbus, Frontend) that are now managed as independent deployments. These services now require a Master Key and a Join Key for mandatory configuration********" -}}
{{- if and $joinOk (not $masterOk) -}}
{{- print "\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print " 🛑  ERROR: MISSING MASTER_KEY (Artifactory)\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "Join key is already provided; you still need the master key.\n\n" -}}
{{- print "👉 STEP 1: PROVIDE MASTER KEY\n" -}}
{{- print "   • FRESH INSTALL — GENERATE A MASTER KEY:\n" -}}
{{- print "       export MASTER_KEY=$(openssl rand -hex 32)\n\n" -}}
{{- print "   • UPGRADE — RETRIEVE EXISTING KEY FROM NODE (Via CLI):\n" -}}
{{- printf "       export MASTER_KEY=$(kubectl exec -it %s-0 -n %s -c %s -- cat /opt/jfrog/artifactory/var/etc/security/master.key)\n\n" (include "artifactory.fullname" .) .Release.Namespace .Values.artifactory.name -}}
{{- print "👉 STEP 2: PASS KEY VIA HELM VALUES\n" -}}
{{- print "    OPTION 1: (Production Recommended): PASS KUBERNETES SECRETS VIA HELM VALUES \n\n" -}}
{{- print "      Create a kubernetes secret\n\n" -}}
{{- print "      kubectl create secret generic artifactory-mandatory-keys -n <namespace> \\\n" -}}
{{- print "      --from-literal=master-key=${MASTER_KEY} \n\n" -}}
{{- print "      Reference the secret name in helm values\n\n" -}}
{{- print "      --set global.masterKeySecretName=artifactory-mandatory-keys \n\n" -}}
{{- print "    OPTION 2: PASS KEYS VIA HELM VALUES\n" -}}
{{- print "      --set global.masterKey=${MASTER_KEY}\n\n" -}}
{{- print "👉 KEYS EXISTING IN SYSTEM YAML: If keys are already defined in system.yaml(via extraSystemYaml, systemYaml, or systemYamlOverride), skip previous steps and use the flag\n" -}}
{{- print "   - --set keysPassedViaSystemyaml=true\n\n" -}}
{{- print "📚 TO LEARN MORE:\n" -}}
{{- print "    https://docs.jfrog.com/installation/docs/helm-charts#install-jfrog-artifactory-using-helm\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- else if and $masterOk (not $joinOk) -}}
{{- print "\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print " 🛑  ERROR: MISSING JOIN_KEY (Artifactory)\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "Master key is already provided; you still need the join key.\n\n" -}}
{{- print "👉 STEP 1: PROVIDE JOIN KEY\n" -}}
{{- print "   • FRESH INSTALL — GENERATE A JOIN KEY:\n" -}}
{{- print "       export JOIN_KEY=$(openssl rand -hex 32)\n\n" -}}
{{- print "   • UPGRADE — RETRIEVE EXISTING JOIN KEY (Via UI):\n" -}}
{{- print "       Administration -> Security -> General -> Connection Details\n" -}}
{{- print "       -> Enter Password -> Join Key (copy to JOIN_KEY env)\n\n" -}}
{{- print "👉 STEP 2: PASS JOIN KEY TO HELM\n" -}}
{{- print "    OPTION 1: (Production Recommended): PASS KUBERNETES SECRETS VIA HELM VALUES \n\n" -}}
{{- print "      Create a kubernetes secret\n\n" -}}
{{- print "      kubectl create secret generic artifactory-mandatory-keys -n <namespace> \\\n" -}}
{{- print "      --from-literal=join-key=${JOIN_KEY} \n\n" -}}
{{- print "      Reference the secret name in helm values\n\n" -}}
{{- print "      --set global.joinKeySecretName=artifactory-mandatory-keys \n\n" -}}
{{- print "    OPTION 2: PASS KEYS VIA HELM VALUES\n" -}}
{{- print "      --set global.joinKey=${JOIN_KEY}\n\n" -}}
{{- print "👉 KEYS EXISTING IN SYSTEM YAML: If keys are already defined in system.yaml(via extraSystemYaml, systemYaml, or systemYamlOverride), skip previous steps and use the flag\n" -}}
{{- print "   - --set keysPassedViaSystemyaml=true\n\n" -}}
{{- print "📚 TO LEARN MORE:\n" -}}
{{- print "    https://docs.jfrog.com/installation/docs/helm-charts#install-jfrog-artifactory-using-helm\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- else -}}
{{- print "\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print " 🛑  ERROR: MISSING MANDATORY KEYS (Artifactory)\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "Artifactory requires a Master Key and a Join Key.\n\n" -}}
{{- print "👉 STEP 1: PROVIDE KEYS\n" -}}
{{- print "   • FRESH INSTALL — GENERATE SECURE KEYS:\n" -}}
{{- print "       export MASTER_KEY=$(openssl rand -hex 32)\n" -}}
{{- print "       export JOIN_KEY=$(openssl rand -hex 32)\n\n" -}}
{{- print "   • UPGRADE — RETRIEVE EXISTING KEYS:\n" -}}
{{- print "       JOIN KEY (Via UI):\n" -}}
{{- print "         Administration -> Security -> General -> Connection Details\n" -}}
{{- print "         -> Enter Password -> Join Key (copy to JOIN_KEY env)\n" -}}
{{- print "       MASTER KEY (Via CLI):\n" -}}
{{- printf "         export MASTER_KEY=$(kubectl exec -it %s-0 -n %s -c %s -- cat /opt/jfrog/artifactory/var/etc/security/master.key)\n\n" (include "artifactory.fullname" .) .Release.Namespace .Values.artifactory.name -}}
{{- print "👉 STEP 2: PASS KEYS TO HELM\n" -}}
{{- print "    OPTION 1: (Production Recommended): PASS KUBERNETES SECRETS VIA HELM VALUES\n\n" -}}
{{- print "      Create a kubernetes secret\n\n" -}}
{{- print "      kubectl create secret generic artifactory-mandatory-keys -n <namespace> \\\n" -}}
{{- print "      --from-literal=master-key=${MASTER_KEY} \\\n" -}}
{{- print "      --from-literal=join-key=${JOIN_KEY}\n\n" -}}
{{- print "      Reference the secret name in helm values\n\n" -}}
{{- print "      --set global.masterKeySecretName=artifactory-mandatory-keys \\\n" -}}
{{- print "      --set global.joinKeySecretName=artifactory-mandatory-keys\n\n" -}}
{{- print "    OPTION 2: PASS KEYS VIA HELM VALUES\n" -}}
{{- print "      --set global.masterKey=${MASTER_KEY} \\\n" -}}
{{- print "      --set global.joinKey=${JOIN_KEY}\n\n" -}}
{{- print "👉 KEYS EXISTING IN SYSTEM YAML: If keys are already defined in system.yaml(via extraSystemYaml, systemYaml, or systemYamlOverride), skip previous steps and use the flag\n" -}}
{{- print "    - --set keysPassedViaSystemyaml=true\n\n" -}}
{{- print "📚 TO LEARN MORE:\n" -}}
{{- print "    https://docs.jfrog.com/installation/docs/helm-charts#install-jfrog-artifactory-using-helm\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "\n" -}}
{{- end -}}
{{- end -}}

{{- define "artifactory.aimlValidationFailMessage" -}}
{{- print "\n********JFrog AIML mode (ml.enabled) integrates Artifactory with JFrog ML, which is delivered through the JFConnect service********" -}}
{{- print "\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print " 🛑  ERROR: AIML REQUIRES JFCONNECT SERVICE (Artifactory)\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "You have enabled AIML features (`ml.enabled=true`), but the required supporting\n" -}}
{{- print "service, JFConnect, has been explicitly disabled (`jfconnect.enabled=false`).\n\n" -}}
{{- print "JFConnect must be enabled to use AIML. It's enabled by default. Re-enable if it's been disabled.\n\n" -}}
{{- print "👉 REMEDIATION:\n" -}}
{{- print "  • To use AIML features, ensure JFConnect remains enabled (remove the disable flag):\n" -}}
{{- print "    --set jfconnect.enabled=true\n\n\n" -}}
{{- print "  • If you intentionally disabled JFConnect, you must also disable AIML:\n" -}}
{{- print "    --set ml.enabled=false\n\n" -}}
{{- print "📚 TO LEARN MORE:\n" -}}
{{- print "  https://docs.jfrog.com/installation/docs/activate-ai-ml\n" -}}
{{- print "\n" -}}
{{- end -}}

{{- define "artifactory.aimlAirgapValidationFailMessage" -}}
{{- print "\n********JFrog AIML mode (ml.enabled) requires a direct internet connection to https://grpc.qwak.ai (proxy not supported), which is not available in an air-gapped environment********" -}}
{{- print "\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print " 🛑  ERROR: AIML IS NOT SUPPORTED IN AIR-GAPPED ENVIRONMENT (Artifactory)\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "You have enabled AIML features (`ml.enabled=true`), but your environment is\n" -}}
{{- print "configured as air-gapped (`jfconnect.airgap.enabled=true`).\n\n" -}}
{{- print "JFrog AIML features require a direct outbound internet connection to\n" -}}
{{- print "https://grpc.qwak.ai (proxies are not supported). It cannot function in an air-gapped environment.\n\n" -}}
{{- print "👉 REMEDIATION:\n" -}}
{{- print "  • If your environment must remain air-gapped, you must disable AIML:\n" -}}
{{- print "    --set ml.enabled=false\n\n" -}}
{{- print "  • To use AIML, disable air-gapped mode and allow direct outbound traffic to grpc.qwak.ai:\n" -}}
{{- print "    --set jfconnect.airgap.enabled=false\n\n" -}}
{{- print "📚 TO LEARN MORE:\n" -}}
{{- print "  https://docs.jfrog.com/installation/docs/activate-ai-ml\n" -}}
{{- print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" -}}
{{- print "\n" -}}
{{- end -}}
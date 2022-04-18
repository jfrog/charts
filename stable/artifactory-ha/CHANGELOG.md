# JFrog Artifactory-ha Chart Changelog
All changes to this chart will be documented in this file.

## [107.37.14] - Mar 08, 2022
* Added support for customPorts in nginx deployment
* Bugfix - Wrong proxy_pass configurations for /artifactory/ in the default artifactory.conf
* Added signedUrlExpirySeconds option to artifactory.persistence.type aws-S3-V3
* Updated router version to `7.35.0`
* Added useInstanceCredentials,enableSignedUrlRedirect option to google-storage-v2
* Changed dependency charts repo to `charts.jfrog.io`

## [107.36.0] - Mar 03, 2022
* Remove pdn tracker which starts replicator service
* Added silent option for curl probes
* Added readiness health check for the artifactory container for k8s version < 1.20
* Fix property file migration issue to system.yaml 6.x to 7.x

## [107.35.0] - Feb 08, 2022
* Updated router version to `7.32.1`

## [107.33.0] - Jan 11, 2022
* Make default value of anti-affinity to soft
* Readme fixes
* Added support for setting `fsGroupChangePolicy`
* Added nginx customInitContainers, customVolumes, customSidecarContainers [GH-1565](https://github.com/jfrog/charts/pull/1565)
* Updated router version to `7.30.0`

## [107.32.0] - Dec 23, 2021
* Updated logger image to `jfrog/ubi-minimal:8.5-204`
* Added default `8091` as `artifactory.tomcat.maintenanceConnector.port` for probes check
* Refactored probes to replace httpGet probes with basic exec + curl
* Refactored `database-creds` secret to create only when database values are passed
* Added new endpoints for probes `/artifactory/api/v1/system/liveness` and `/artifactory/api/v1/system/readiness`
* Enabled `newProbes:true` by default to use these endpoints
* Fix filebeat sidecar spool file permissions
* Updated filebeat sidecar container to `7.16.2`

## [107.31.0] - Dec 17, 2021
* Remove integration service feature flag to make it mandatory service
* Update postgresql tag version to `13.4.0-debian-10-r39`
* Refactored `router.requiredServiceTypes` to support platform chart

## [107.30.0] - Nov 30, 2021
* Fixed incorrect permission for filebeat.yaml
* Updated healthcheck (liveness/readiness) api for integration service
* Disable readiness health check for the artifactory container when running in the container split mode
* Ability to start replicator on enabling pdn tracker

## [107.29.0] - Nov 30, 2021
* Added integration service container in artifactory
* Add support for Ingress Class Name in Ingress Spec [GH-1516](https://github.com/jfrog/charts/pull/1516)
* Fixed chart values to use curl instead of wget [GH-1529](https://github.com/jfrog/charts/issues/1529)
* Updated nginx config to allow websockets when pipelines is enabled
* Moved router.topology.local.requireqservicetypes from system.yaml to router as environment variable
* Added jfconnect in system.yaml
* Updated artifactory container’s health probes to use artifactory api on rt-split
* Updated initContainerImage to `jfrog/ubi-minimal:8.5-204`
* Updated router version to `7.28.2`
* Set Jfconnect enabled to `false` in the artifactory container when running in the container split mode

## [107.28.0] - Nov 11, 2021
* Added default values cpu and memeory in initContainers
* Updated router version to `7.26.0`
* Bug fix - jmx port not exposed in artifactory service
* Updated (`rbac.create` and `serviceAccount.create` to false by default) for least privileges
* Fixed incorrect data type for `Values.router.serviceRegistry.insecure` in default values.yaml [GH-1514](https://github.com/jfrog/charts/pull/1514/files)
* **IMPORTANT**
* Changed init-container images from `alpine` to `ubi8/ubi-minimal`
* Added support for AWS License Manager using `.Values.aws.licenseConfigSecretName`

## [107.27.0] - Oct 6, 2021
* **Breaking change**
* Aligned probe structure (moved probes variables under config block)
* Added support for new probes(set to false by default)
* Bugfix - Invalid format for `multiPartLimit,multipartElementSize,maxCacheSize` in binarystore.xml [GH-1466](https://github.com/jfrog/charts/issues/1466)
* Added missioncontrol container in artifactory
* Dropped NET_RAW capability for the containers
* Added resources to migration-artifactory init container
* Added resources to all rt split containers
* Updated router version to `7.25.1`
* Added support for Ingress networking.k8s.io/v1/Ingress for k8s >=1.22 [GH-1487](https://github.com/jfrog/charts/pull/1487)
* Added min kubeVersion ">= 1.14.0-0" in chart.yaml
* Update alpine tag version to `3.14.2`
* Update busybox tag version to `1.33.1`
* Update postgresql tag version to `13.4.0-debian-10-r39`

## [107.26.0] - Aug 20, 2021
* Added Observability container (only when `splitServicesToContainers` is enabled)
* Added min kubeVersion ">= 1.12.0-0" in chart.yaml

## [107.25.0] - Aug 13, 2021
* Updated readme of chart to point to wiki. Refer [Installing Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory)
* Added startupProbe and livenessProbe for RT-split containers
* Updated router version to 7.24.1
* Added security hardening fixes
* Enabled startup probes for k8s >= 1.20.x
* Changed network policy to allow all ingress and egress traffic
* Added Observability changes
* Added support for global.versions.router (only when `splitServicesToContainers` is enabled)

## [107.24.0] - July 27, 2021
* Support global and product specific tags at the same time
* Added support for artifactory containers split

## [107.23.0] - July 8, 2021
* Bug fix - logger sideCar picks up Wrong File in helm
* Allow filebeat metrics configuration in values.yaml

## [107.22.0] - July 6, 2021
* Update alpine tag version to `3.14.0`
* Added `nodePort` support to artifactory-service and nginx-service templates
* Removed redundant `terminationGracePeriodSeconds` in statefulset
* Increased `startupProbe.failureThreshold` time

## [107.21.3] - July 2, 2021
* Added ability to change sendreasonphrase value in server.xml via system yaml

## [107.19.3] - May 20, 2021
* Fix broken support for startupProbe for k8s < 1.18.x
* Removed an extraneous resources block from the prepare-custom-persistent-volume container in the primary statefulset
* Added support for `nameOverride` and `fullnameOverride` in values.yaml

## [107.18.6] - May 4, 2021
* Removed `JF_SHARED_NODE_PRIMARY` env to support for Cloud Native HA
* Bumping chart version to align with app version
* Add `securityContext` option on nginx container

## [5.0.0] - April 22, 2021
* **Breaking change:** 
* Increased default postgresql persistence  size to `200Gi` 
* Update postgresql tag version to `13.2.0-debian-10-r55`
* Update postgresql chart version to `10.3.18` in chart.yaml - [10.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#to-1000)
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* **IMPORTANT**
* This chart is only helm v3 compatible
* Fix support for Cloud Native HA
* Fixed filebeat-configmap naming
* Explicitly set ServiceAccount `automountServiceAccountToken` to 'true'
* Update alpine tag version to `3.13.5`

## [4.13.2] - April 15, 2021
* Updated Artifactory version to 7.17.9 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.17.9)

## [4.13.1] - April 6, 2021
* Updated Artifactory version to 7.17.6 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.17.6)
* Update alpine tag version to `3.13.4`

## [4.13.0] - April 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository
* Updated Artifactory version to 7.17.5 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.17.5)

## [4.12.2] - Mar 31, 2021
* Updated Artifactory version to 7.17.4 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.17.4)

## [4.12.1] - Mar 30, 2021
* Updated Artifactory version to 7.17.3
* Add `timeoutSeconds` to all exec probes - Please refer [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)

## [4.12.0] - Mar 24, 2021
* Updated Artifactory version to 7.17.2
* Optimized startupProbe time

## [4.11.0] - Mar 18, 2021
* Add support to startupProbe

## [4.10.0] - Mar 15, 2021
* Updated Artifactory version to 7.16.3

## [4.9.5] - Mar 09, 2021
* Added HSTS header to nginx conf

## [4.9.4] - Mar 9, 2021
* Removed bintray URL references in the chart

## [4.9.3] - Mar 04, 2021
* Updated Artifactory version to 7.15.4 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.15.4)

## [4.9.2] - Mar 04, 2021
* Fixed creation of nginx-certificate-secret when Nginx is disabled

## [4.9.1] - Feb 19, 2021
* Update busybox tag version to `1.32.1`

## [4.9.0] - Feb 18, 2021
* Updated Artifactory version to 7.15.3 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.15.3)
* Add option to specify update strategy for Artifactory statefulset

## [4.8.1] - Feb 11, 2021
* Exposed "multiPartLimit" and "multipartElementSize" for the Azure Blob Storage Binary Provider

## [4.8.0] - Feb 08, 2021
* Updated Artifactory version to 7.12.8 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.12.8)
* Support for custom certificates using secrets
* **Important:** Switched docker images download from `docker.bintray.io` to `releases-docker.jfrog.io`
* Update alpine tag version to `3.13.1`

## [4.7.9] - Feb 3, 2021
* Fix copyOnEveryStartup for HA cluster license

## [4.7.8] - Jan 25, 2021
* Add support for hostAliases

## [4.7.7] - Jan 11, 2021
* Fix failures when using creds file for configurating google storage

## [4.7.6] - Jan 11, 2021
* Updated Artifactory version to 7.12.6 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.12.6)

## [4.7.5] - Jan 07, 2021
* Added support for optional tracker dedicated ingress `.Values.artifactory.replicator.trackerIngress.enabled` (defaults to false)

## [4.7.4] - Jan 04, 2021
* Fixed gid support for statefulset

## [4.7.3] - Dec 31, 2020
* Added gid support for statefulset
* Add setSecurityContext flag to allow securityContext block to be removed from artifactory statefulset

## [4.7.2] - Dec 29, 2020
* **Important:** Removed `.Values.metrics` and `.Values.fluentd` (Fluentd and Prometheus integrations)
* Add support for creating additional kubernetes resources - [refer here](https://github.com/jfrog/log-analytics-prometheus/blob/master/artifactory-ha-values.yaml)
* Updated Artifactory version to 7.12.5

## [4.7.1] - Dec 21, 2020
* Updated Artifactory version to 7.12.3

## [4.7.0] - Dec 18, 2020
* Updated Artifactory version to 7.12.2
* Added `.Values.artifactory.openMetrics.enabled`

## [4.6.1] - Dec 11, 2020
* Added configurable `.Values.global.versions.artifactory` in values.yaml

## [4.6.0] - Dec 10, 2020
* Update postgresql tag version to `12.5.0-debian-10-r25`
* Fixed `artifactory.persistence.googleStorage.endpoint` from `storage.googleapis.com` to `commondatastorage.googleapis.com`
* Updated chart maintainers email

## [4.5.5] - Dec 4, 2020
* **Important:** Renamed `.Values.systemYaml` to `.Values.systemYamlOverride`

## [4.5.4] - Dec 1, 2020
* Improve error message returned when attempting helm upgrade command

## [4.5.3] - Nov 30, 2020
* Updated Artifactory version to 7.11.5 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.11)

# [4.5.2] - Nov 23, 2020
* Updated Artifactory version to 7.11.2 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.11)
* Updated port namings on services and pods to allow for istio protocol discovery
* Change semverCompare checks to support hosted Kubernetes
* Add flag to disable creation of ServiceMonitor when enabling prometheus metrics
* Prevent the PostHook command to be executed if the user did not specify a command in the values file
* Fix issue with tls file generation when nginx.https.enabled is false

## [4.5.1] - Nov 19, 2020
* Updated Artifactory version to 7.11.2
* Bugfix - access.config.import.xml override Access Federation configurations

## [4.5.0] - Nov 17, 2020
* Updated Artifactory version to 7.11.1
* Update alpine tag version to `3.12.1`

## [4.4.6] - Nov 10, 2020
* Pass system.yaml via external secret for advanced usecases
* Added support for custom ingress
* Bugfix - stateful set not picking up changes to database secrets

## [4.4.5] - Nov 9, 2020
* Updated Artifactory version to 7.10.6 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.10.6)

## [4.4.4] - Nov 2, 2020
* Add enablePathStyleAccess property for aws-s3-v3 binary provider template

## [4.4.3] - Nov 2, 2020
* Updated Artifactory version to 7.10.5 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.10.5)

## [4.4.2] - Oct 22, 2020
* Chown bug fix where Linux capability cannot chown all files causing log line warnings
* Fix Frontend timeout linting issue

## [4.4.1] - Oct 20, 2020
* Add flag to disable prepare-custom-persistent-volume init container

## [4.4.0] - Oct 19, 2020
* Updated Artifactory version to 7.10.2 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.10.2)

## [4.3.4] - Oct 19, 2020
* Add support to specify priorityClassName for nginx deployment

## [4.3.3] - Oct 15, 2020
* Fixed issue with node PodDisruptionBudget which also getting applied on the primary
* Fix mandatory masterKey check issue when upgrading from 6.x to 7.x

## [4.3.2] - Oct 14, 2020
* Add support to allow more than 1 Primary in Artifactory-ha STS

## [4.3.1] - Oct 9, 2020
* Add global support for customInitContainersBegin

## [4.3.0] - Oct 07, 2020
* Updated Artifactory version to 7.9.1
* **Breaking change:** Fix `storageClass` to correct `storageClassName` in values.yaml

## [4.2.0] - Oct 5, 2020
* Expose Prometheus metrics via a ServiceMonitor
* Parse log files for metric data with Fluentd

## [4.1.0] - Sep 30, 2020
* Updated Artifactory version to 7.9.0 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.9)

## [4.0.12] - Sep 25, 2020
* Update to use linux capability CAP_CHOWN instead of root base init container to avoid any use of root containers to pass Redhat security requirements

## [4.0.11] - Sep 28, 2020
* Setting chart coordinates in migitation yaml

## [4.0.10] - Sep 25, 2020
* Update filebeat version to `7.9.2`

## [4.0.9] - Sep 24, 2020
* Fixed broken issue - when setting `waitForDatabase:false` container startup still waits for DB

## [4.0.8] - Sep 22, 2020
* Updated readme

## [4.0.7] - Sep 22, 2020
* Fix lint issue in migitation yaml

## [4.0.6] - Sep 22, 2020
* Fix broken migitation yaml

## [4.0.5] - Sep 21, 2020
* Added mitigation yaml for Artifactory - [More info](https://github.com/jfrog/chartcenter/blob/master/docs/securitymitigationspec.md)

## [4.0.4] - Sep 17, 2020
* Added configurable session(UI) timeout in frontend microservice

## [4.0.3] - Sep 17, 2020
* Fix small typo in README and added proper required text to be shown while postgres upgrades

## [4.0.2] - Sep 14, 2020
* Updated Artifactory version to 7.7.8 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.7.8)

## [4.0.1] - Sep 8, 2020
* Added support for artifactory pro license (single node) installation.

## [4.0.0] - Sep 2, 2020
* **Breaking change:** Changed `imagePullSecrets` value from string to list
* **Breaking change:** Added `image.registry` and changed `image.version` to `image.tag` for docker images
* Added support for global values
* Updated maintainers in chart.yaml
* Update postgresql tag version to `12.3.0-debian-10-r71`
* Update postgresqlsub chart version to `9.3.4` - [9.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#900)
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x's postgresql.image.tag and databaseUpgradeReady=true.

## [3.1.0] - Aug 13, 2020
* Updated Artifactory version to 7.7.3 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.7)

## [3.0.15] - Aug 10, 2020
* Added enableSignedUrlRedirect for persistent storage type aws-s3-v3.

## [3.0.14] - Jul 31, 2020
* Update the README section on Nginx SSL termination to reflect the actual YAML structure.

## [3.0.13] - Jul 30, 2020
* Added condition to disable the migration scripts.

## [3.0.12] - Jul 29, 2020
* Document Artifactory node affinity.

## [3.0.11] - Jul 28, 2020
* Added maxConnections for persistent storage type aws-s3-v3.

## [3.0.10] - Jul 28, 2020
Bugfix / support for userPluginSecrets with Artifactory 7

## [3.0.9] - Jul 27, 2020
* Add tpl to external database secrets.
* Modified `scheme`  to `artifactory-ha.scheme`

## [3.0.8] - Jul 23, 2020
* Added condition to disable the migration init container.

## [3.0.7] - Jul 21, 2020
* Updated Artifactory-ha Chart to add node and primary labels to pods and service objects.

## [3.0.6] - Jul 20, 2020
* Support custom CA and certificates

## [3.0.5] - Jul 13, 2020
* Updated Artifactory version to 7.6.3 - https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.6.3
* Fixed Mysql database jar path in `preStartCommand` in README

## [3.0.4] - Jul 8, 2020
* Move some postgresql values to where they should be according to the subchart

## [3.0.3] - Jul 8, 2020
* Set Artifactory access client connections to the same value as the access threads.

## [3.0.2] - Jul 6, 2020
* Updated Artifactory version to 7.6.2
* **IMPORTANT**
* Added ChartCenter Helm repository in README

## [3.0.1] - Jul 01, 2020
* Add dedicated ingress object for Replicator service when enabled

## [3.0.0] - Jun 30, 2020
* Update postgresql tag version to `10.13.0-debian-10-r38`
* Update alpine tag version to `3.12`
* Update busybox tag version to `1.31.1`
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass postgresql.image.tag=9.6.18-debian-10-r7 and databaseUpgradeReady=true

## [2.6.0] - Jun 29, 2020
* Updated Artifactory version to 7.6.1 - https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.6.1
* Add tpl for external database secrets

## [2.5.8] - Jun 25, 2020
* Stop loading the Nginx stream module because it is now a core module

## [2.5.7] - Jun 18, 2020
* Fixes bootstrap configMap issue on member node

## [2.5.6] - Jun 11, 2020
* Support list of custom secrets

## [2.5.5] - Jun 11, 2020
* NOTES.txt fixed incorrect information

## [2.5.4] - Jun 12, 2020
* Updated Artifactory version to 7.5.7 - https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.5.7

## [2.5.3] - Jun 8, 2020
* Statically setting primary service type to ClusterIP.
* Prevents primary service from being exposed publicly when using LoadBalancer type on cloud providers.

## [2.5.2] - Jun 8, 2020
* Readme update - configuring Artifactory with oracledb

## [2.5.1] - Jun 5, 2020
* Fixes broken PDB issue upgrading from 6.x to 7.x

## [2.5.0] - Jun 1, 2020
* Updated Artifactory version to 7.5.5 - https://www.jfrog.com/confluence/display/JFROG/Artifactory+Release+Notes#ArtifactoryReleaseNotes-Artifactory7.5
* Fixes bootstrap configMap permission issue
* Update postgresql tag version to `9.6.18-debian-10-r7`

## [2.4.10] - May 27, 2020
* Added Tomcat maxThreads & acceptCount

## [2.4.9] - May 25, 2020
* Fixed postgresql README `image` Parameters

## [2.4.8] - May 24, 2020
* Fixed typo in README regarding migration timeout

## [2.4.7] - May 19, 2020
* Added metadata maxOpenConnections

## [2.4.6] - May 07, 2020
* Fix `installerInfo` string format

## [2.4.5] - Apr 27, 2020
* Updated Artifactory version to 7.4.3

## [2.4.4] - Apr 27, 2020
* Change customInitContainers order to run before the "migration-ha-artifactory" initContainer

## [2.4.3] - Apr 24, 2020
* Fix `artifactory.persistence.awsS3V3.useInstanceCredentials` incorrect conditional logic
* Bump postgresql tag version to `9.6.17-debian-10-r72` in values.yaml

## [2.4.2] - Apr 16, 2020
* Custom volume mounts in migration init container.

## [2.4.1] - Apr 16, 2020
* Fix broken support for gcpServiceAccount for googleStorage

## [2.4.0] - Apr 14, 2020
* Updated Artifactory version to 7.4.1

## [2.3.1] - April 13, 2020
* Update README with helm v3 commands

## [2.3.0] - April 10, 2020
* Use dependency charts from `https://charts.bitnami.com/bitnami`
* Bump postgresql chart version to `8.7.3` in requirements.yaml
* Bump postgresql tag version to `9.6.17-debian-10-r21` in values.yaml

## [2.2.11] - Apr 8, 2020
* Added recommended ingress annotation to avoid 413 errors

## [2.2.10] - Apr 8, 2020
* Moved migration scripts under `files` directory
* Support preStartCommand in migration Init container as `artifactory.migration.preStartCommand`

## [2.2.9] - Apr 01, 2020
* Support masterKey and joinKey as secrets

## [2.2.8] - Apr 01, 2020
* Ensure that the join key is also copied when provided by an external secret
* Migration container in primary and node statefulset now respects custom versions and the specified node/primary resources

## [2.2.7] - Apr 01, 2020
* Added cache-layer in chain definition of Google Cloud Storage template
* Fix readme use to `-hex 32` instead of `-hex 16`

## [2.2.6] - Mar 31, 2020
* Change the way the artifactory `command:` is set so it will properly pass a SIGTERM to java

## [2.2.5] - Mar 31, 2020
* Removed duplicate `artifactory-license` volume from primary node

## [2.2.4] - Mar 31, 2020
* Restore `artifactory-license` volume for the primary node

## [2.2.3] - Mar 29, 2020
* Add Nginx log options: stderr as logfile and log level

## [2.2.2] - Mar 30, 2020
* Apply initContainers.resources to `copy-system-yaml`, `prepare-custom-persistent-volume`, and `migration-artifactory-ha` containers
* Use the same defaulting mechanism used for the artifactory version used elsewhere in the chart
* Removed duplicate `artifactory-license` volume that prevented using an external secret

## [2.2.1] - Mar 29, 2020
* Fix loggers sidecars configurations to support new file system layout and new log names

## [2.2.0] - Mar 29, 2020
* Fix broken admin user bootstrap configuration
* **Breaking change:** renamed `artifactory.accessAdmin` to `artifactory.admin`

## [2.1.3] - Mar 24, 2020
* Use `postgresqlExtendedConf` for setting custom PostgreSQL configuration (instead of `postgresqlConfiguration`)

## [2.1.2] - Mar 21, 2020
* Support for SSL offload in Nginx service(LoadBalancer) layer. Introduced `nginx.service.ssloffload` field with boolean type.

## [2.1.1] - Mar 23, 2020
* Moved installer info to values.yaml so it is fully customizable

## [2.1.0] - Mar 23, 2020
* Updated Artifactory version to 7.3.2

## [2.0.36] - Mar 20, 2020
* Add support GCP credentials.json authentication

## [2.0.35] - Mar 20, 2020
* Add support for masterKey trim during 6.x to 7.x migration if 6.x masterKey is 32 hex (64 characters)

## [2.0.34] - Mar 19, 2020
* Add support for NFS directories `haBackupDir` and `haDataDir`

## [2.0.33] - Mar 18, 2020
* Increased Nginx proxy_buffers size

## [2.0.32] - Mar 17, 2020
* Changed all single quotes to double quotes in values files
* useInstanceCredentials variable was declared in S3 settings but not used in chart. Now it is being used.

## [2.0.31] - Mar 17, 2020
* Fix rendering of Service Account annotations

## [2.0.30] - Mar 16, 2020
* Add Unsupported message from 6.18 to 7.2.x (migration)

## [2.0.29] - Mar 11, 2020
* Upgrade Docs update

## [2.0.28] - Mar 11, 2020
* Unified charts public release

## [2.0.27] - Mar 8, 2020
* Add an optional wait for primary node to be ready with a proper test for http status

## [2.0.23] - Mar 6, 2020
* Fix path to `/artifactory_bootstrap`
* Add support for controlling the name of the ingress and allow to set more than one cname

## [2.0.22] - Mar 4, 2020
* Add support for disabling `consoleLog` in `system.yaml` file

## [2.0.21] - Feb 28, 2020
* Add support to process `valueFrom` for extraEnvironmentVariables

## [2.0.20] - Feb 26, 2020
* Store join key to secret

## [2.0.19] - Feb 26, 2020
* Updated Artifactory version to 7.2.1

## [2.0.12] - Feb 07, 2020
* Remove protection flag `databaseUpgradeReady` which was added to check internal postgres upgrade

## [2.0.0] - Feb 07, 2020
* Updated Artifactory version to 7.0.0

## [1.4.10] - Feb 13, 2020
* Add support for SSH authentication to Artifactory

## [1.4.9] - Feb 10, 2020
* Fix custom DB password indention

## [1.4.8] - Feb 9, 2020
* Add support for `tpl` in the `postStartCommand`

## [1.4.7] - Feb 4, 2020
* Support customisable Nginx kind

## [1.4.6] - Feb 2, 2020
* Add a comment stating that it is recommended to use an external PostgreSQL with a static password for production installations

## [1.4.5] - Feb 2, 2020
* Add support for primary or member node specific preStartCommand

## [1.4.4] - Jan 30, 2020
* Add the option to configure resources for the logger containers

## [1.4.3] - Jan 26, 2020
* Improve `database.user` and `database.password` logic in order to support more use cases and make the configuration less repetitive

## [1.4.2] - Jan 22, 2020
* Refined pod disruption budgets to separate nginx and Artifactory pods

## [1.4.1] - Jan 19, 2020
* Fix replicator port config in nginx replicator configmap

## [1.4.0] - Jan 19, 2020
* Updated Artifactory version to 6.17.0

## [1.3.8] - Jan 16, 2020
* Added example for external nginx-ingress

## [1.3.7] - Jan 07, 2020
* Add support for customizable `mountOptions` of NFS PVs

## [1.3.6] - Dec 30, 2019
* Fix for nginx probes failing when launched with http disabled

## [1.3.5] - Dec 24, 2019
* Better support for custom `artifactory.internalPort`

## [1.3.4] - Dec 23, 2019
* Mark empty map values with `{}`

## [1.3.3] - Dec 16, 2019
* Another fix for toggling nginx service ports

## [1.3.2] - Dec 12, 2019
* Fix for toggling nginx service ports

## [1.3.1] - Dec 10, 2019
* Add support for toggling nginx service ports

## [1.3.0] - Dec 1, 2019
* Updated Artifactory version to 6.16.0

## [1.2.4] - Nov 28, 2019
* Add support for using existing PriorityClass

## [1.2.3] - Nov 27, 2019
* Add support for PriorityClass

## [1.2.2] - Nov 20, 2019
* Update Artifactory logo

## [1.2.1] - Nov 18, 2019
* Add the option to provide service account annotations (in order to support stuff like https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)

## [1.2.0] - Nov 18, 2019
* Updated Artifactory version to 6.15.0

## [1.1.12] - Nov 17, 2019
* Fix `README.md` format (broken table)

## [1.1.11] - Nov 17, 2019
* Update comment on Artifactory master key

## [1.1.10] - Nov 17, 2019
* Fix creation of double slash in nginx artifactory configuration

## [1.1.9] - Nov 14, 2019
* Set explicit `postgresql.postgresqlPassword=""` to avoid helm v3 error

## [1.1.8] - Nov 12, 2019
* Updated Artifactory version to 6.14.1

## [1.1.7] - Nov 11, 2019
* Additional documentation for masterKey

## [1.1.6] - Nov 10, 2019
* Update PostgreSQL chart version to 7.0.1
* Use formal PostgreSQL configuration format

## [1.1.5] - Nov 8, 2019
* Add support `artifactory.service.loadBalancerSourceRanges` for whitelisting when setting `artifactory.service.type=LoadBalancer`

## [1.1.4] - Nov 6, 2019
* Add support for any type of environment variable by using `extraEnvironmentVariables` as-is

## [1.1.3] - Nov 6, 2019
* Add nodeselector support for Postgresql

## [1.1.2] - Nov 5, 2019
* Add support for the aws-s3-v3 filestore, which adds support for pod IAM roles

## [1.1.1] - Nov 4, 2019
* When using `copyOnEveryStartup`, make sure that the target base directories are created before copying the files

## [1.1.0] - Nov 3, 2019
* Updated Artifactory version to 6.14.0

## [1.0.1] - Nov 3, 2019
* Make sure the artifactory pod exits when one of the pre-start stages fail

## [1.0.0] - Oct 27, 2019
**IMPORTANT - BREAKING CHANGES!**<br>
**DOWNTIME MIGHT BE REQUIRED FOR AN UPGRADE!**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), must use the upgrade instructions in [UPGRADE_NOTES.md](UPGRADE_NOTES.md)!
* PostgreSQL sub chart was upgraded to version `6.5.x`. This version is **not backward compatible** with the old version (`0.9.5`)!
* Note the following **PostgreSQL** Helm chart changes
  * The chart configuration has changed! See [values.yaml](values.yaml) for the new keys used
  * **PostgreSQL** is deployed as a StatefulSet
  * See [PostgreSQL helm chart](https://hub.helm.sh/charts/stable/postgresql) for all available configurations

## [0.17.3] - Oct 24, 2019
* Change the preStartCommand to support templating

## [0.17.2] - Oct 21, 2019
* Add support for setting `artifactory.primary.labels`
* Add support for setting `artifactory.node.labels`
* Add support for setting `nginx.labels`

## [0.17.1] - Oct 10, 2019
* Updated Artifactory version to 6.13.1

## [0.17.0] - Oct 7, 2019
* Updated Artifactory version to 6.13.0

## [0.16.7] - Sep 24, 2019
* Option to skip wait-for-db init container with '--set waitForDatabase=false'

## [0.16.6] - Sep 24, 2019
* Add support for setting `nginx.service.labels`

## [0.16.5] - Sep 23, 2019
* Add support for setting `artifactory.customInitContainersBegin`

## [0.16.4] - Sep 20, 2019
* Add support for setting `initContainers.resources`

## [0.16.3] - Sep 11, 2019
* Updated Artifactory version to 6.12.2

## [0.16.2] - Sep 9, 2019
* Updated Artifactory version to 6.12.1

## [0.16.1] - Aug 22, 2019
* Fix the nginx server_name directive used with ingress.hosts

## [0.16.0] - Aug 21, 2019
* Updated Artifactory version to 6.12.0

## [0.15.15] - Aug 18, 2019
* Fix existingSharedClaim permissions issue and example

## [0.15.14] - Aug 14, 2019
* Updated Artifactory version to 6.11.6

## [0.15.13] - Aug 11, 2019
* Fix Ingress routing and add an example

## [0.15.12] - Aug 6, 2019
* Do not mount `access/etc/bootstrap.creds` unless user specifies a custom password or secret (Access already generates a random password if not provided one)
* If custom `bootstrap.creds` is provided (using keys or custom secret), prepare it with an init container so the temp file does not persist

## [0.15.11] - Aug 5, 2019
* Improve binarystore config
    1. Convert to a secret
    2. Move config to values.yaml
    3. Support an external secret

## [0.15.10] - Aug 5, 2019
* Don't create the nginx configmaps when nginx.enabled is false

## [0.15.9] - Aug 1, 2019
* Fix masterkey/masterKeySecretName not specified warning render logic in NOTES.txt

## [0.15.8] - Jul 28, 2019
* Simplify nginx setup and shorten initial wait for probes

## [0.15.7] - Jul 25, 2019
* Updated README about how to apply Artifactory licenses

## [0.15.6] - Jul 22, 2019
* Change Ingress API to be compatible with recent kubernetes versions

## [0.15.5] - Jul 22, 2019
* Updated Artifactory version to 6.11.3

## [0.15.4] - Jul 11, 2019
* Add `artifactory.customVolumeMounts` support to member node statefulset template

## [0.15.3] - Jul 11, 2019
* Add ingress.hosts to the Nginx server_name directive when ingress is enabled to help with Docker repository sub domain configuration

## [0.15.2] - Jul 3, 2019
* Add the option for changing nginx config using values.yaml and remove outdated reverse proxy documentation

## [0.15.1] - Jul 1, 2019
* Updated Artifactory version to 6.11.1

## [0.15.0] - Jun 27, 2019
* Updated Artifactory version to 6.11.0 and Restart Primary node when bootstrap.creds file has been modified in artifactory-ha

## [0.14.4] - Jun 24, 2019
* Add the option to provide an IP for the access-admin endpoints

## [0.14.3] - Jun 24, 2019
* Update chart maintainers

## [0.14.2] - Jun 24, 2019
* Change Nginx to point to the artifactory externalPort

## [0.14.1] - Jun 23, 2019
* Add values files for small, medium and large installations

## [0.14.0] - Jun 20, 2019
* Use ConfigMaps for nginx configuration and remove nginx postStart command

## [0.13.10] - Jun 19, 2019
* Updated Artifactory version to 6.10.4

## [0.13.9] - Jun 18, 2019
* Add the option to provide additional ingress rules

## [0.13.8] - Jun 14, 2019
* Updated readme with improved external database setup example

## [0.13.7] - Jun 6, 2019
* Updated Artifactory version to 6.10.3
* Updated installer-info template

## [0.13.6] - Jun 6, 2019
* Updated Google Cloud Storage API URL and https settings

## [0.13.5] - Jun 5, 2019
* Delete the db.properties file on Artifactory startup

## [0.13.4] - Jun 3, 2019
* Updated Artifactory version to 6.10.2

## [0.13.3] - May 21, 2019
* Updated Artifactory version to 6.10.1

## [0.13.2] - May 19, 2019
* Fix missing logger image tag

## [0.13.1] - May 15, 2019
* Support `artifactory.persistence.cacheProviderDir` for on-premise cluster

## [0.13.0] - May 7, 2019
* Updated Artifactory version to 6.10.0

## [0.12.23] - May 5, 2019
* Add support for setting `artifactory.async.corePoolSize`

## [0.12.22] - May 2, 2019
* Remove unused property `artifactory.releasebundle.feature.enabled`

## [0.12.21] - Apr 30, 2019
* Add support for JMX monitoring

## [0.12.20] - Apr29, 2019
* Added support for headless services

## [0.12.19] - Apr 28, 2019
* Added support for `cacheProviderDir`

## [0.12.18] - Apr 18, 2019
* Changing API StatefulSet version to `v1` and permission fix for custom `artifactory.conf` for Nginx

## [0.12.17] - Apr 16, 2019
* Updated documentation for Reverse Proxy Configuration

## [0.12.16] - Apr 12, 2019
* Added support for `customVolumeMounts`

## [0.12.15] - Aprl 12, 2019
* Added support for `bucketExists` flag for googleStorage

## [0.12.14] - Apr 11, 2019
* Replace `curl` examples with `wget` due to the new base image

## [0.12.13] - Aprl 07, 2019
* Add support for providing the Artifactory license as a parameter

## [0.12.12] - Apr 10, 2019
* Updated Artifactory version to 6.9.1

## [0.12.11] - Aprl 04, 2019
* Add support for templated extraEnvironmentVariables

## [0.12.10] - Aprl 07, 2019
* Change network policy API group

## [0.12.9] - Aprl 04, 2019
* Apply the existing PVC for members (in addition to primary)

## [0.12.8] - Aprl 03, 2019
* Bugfix for userPluginSecrets

## [0.12.7] - Apr 4, 2019
* Add information about upgrading Artifactory with auto-generated postgres password

## [0.12.6] - Aprl 03, 2019
* Added installer info

## [0.12.5] - Aprl 03, 2019
* Allow secret names for user plugins to contain template language

## [0.12.4] - Apr 02, 2019
* Fix issue #253 (use existing PVC for data and backup storage)

## [0.12.3] - Apr 02, 2019
* Allow NetworkPolicy configurations (defaults to allow all)

## [0.12.2] - Aprl 01, 2019
* Add support for user plugin secret

## [0.12.1] - Mar 26, 2019
* Add the option to copy a list of files to ARTIFACTORY_HOME on startup

## [0.12.0] - Mar 26, 2019
* Updated Artifactory version to 6.9.0

## [0.11.18] - Mar 25, 2019
* Add CI tests for persistence, ingress support and nginx

## [0.11.17] - Mar 22, 2019
* Add the option to change the default access-admin password

## [0.11.16] - Mar 22, 2019
* Added support for `<artifactory|nginx>.<readiness|liveness>Probe.path` to customise the paths used for health probes

## [0.11.15] - Mar 21, 2019
* Added support for `artifactory.customSidecarContainers` to create custom sidecar containers
* Added support for `artifactory.customVolumes` to create custom volumes

## [0.11.14] - Mar 21, 2019
* Make ingress path configurable

## [0.11.13] - Mar 19, 2019
* Move the copy of bootstrap config from postStart to preStart for Primary

## [0.11.12] - Mar 19, 2019
* Fix existingClaim example

## [0.11.11] - Mar 18, 2019
* Disable the option to use nginx PVC with more than one replica

## [0.11.10] - Mar 15, 2019
* Wait for nginx configuration file before using it

## [0.11.9] - Mar 15, 2019
* Revert securityContext changes since they were causing issues

## [0.11.8] - Mar 15, 2019
* Fix issue #247 (init container failing to run)

## [0.11.7] - Mar 14, 2019
* Updated Artifactory version to 6.8.7

## [0.11.6] - Mar 13, 2019
* Move securityContext to container level

## [0.11.5] - Mar 11, 2019
* Add the option to use existing volume claims for Artifactory storage

## [0.11.4] - Mar 11, 2019
* Updated Artifactory version to 6.8.6

## [0.11.3] - Mar 5, 2019
* Updated Artifactory version to 6.8.4

## [0.11.2] - Mar 4, 2019
* Add support for catalina logs sidecars

## [0.11.1] - Feb 27, 2019
* Updated Artifactory version to 6.8.3

## [0.11.0] - Feb 25, 2019
* Add nginx support for tail sidecars

## [0.10.3] - Feb 21, 2019
* Add s3AwsVersion option to awsS3 configuration for use with IAM roles

## [0.10.2] - Feb 19, 2019
* Updated Artifactory version to 6.8.2

## [0.10.1] - Feb 17, 2019
* Updated Artifactory version to 6.8.1
* Add example of `SERVER_XML_EXTRA_CONNECTOR` usage

## [0.10.0] - Feb 15, 2019
* Updated Artifactory version to 6.8.0

## [0.9.7] - Feb 13, 2019
* Updated Artifactory version to 6.7.3

## [0.9.6] - Feb 7, 2019
* Add support for tail sidecars to view logs from k8s api

## [0.9.5] - Feb 6, 2019
* Fix support for customizing statefulset `terminationGracePeriodSeconds`

## [0.9.4] - Feb 5, 2019
* Add support for customizing statefulset `terminationGracePeriodSeconds`

## [0.9.3] - Feb 5, 2019
* Remove the inactive server remove plugin

## [0.9.2] - Feb 3, 2019
* Updated Artifactory version to 6.7.2

## [0.9.1] - Jan 27, 2019
* Fix support for Azure Blob Storage Binary provider

## [0.9.0] - Jan 23, 2019
* Updated Artifactory version to 6.7.0

## [0.8.10] - Jan 22, 2019
* Added support for `artifactory.customInitContainers` to create custom init containers

## [0.8.9] - Jan 18, 2019
* Added support of values ingress.labels

## [0.8.8] - Jan 16, 2019
* Mount replicator.yaml (config) directly to /replicator_extra_conf

## [0.8.7] - Jan 15, 2018
* Add support for Azure Blob Storage Binary provider

## [0.8.6] - Jan 13, 2019
* Fix documentation about nginx group id

## [0.8.5] - Jan 13, 2019
* Updated Artifactory version to 6.6.5

## [0.8.4] - Jan 8, 2019
* Make artifactory.replicator.publicUrl required when the replicator is enabled

## [0.8.3] - Jan 1, 2019
* Updated Artifactory version to 6.6.3
* Add support for `artifactory.extraEnvironmentVariables` to pass more environment variables to Artifactory

## [0.8.2] - Dec 28, 2018
* Fix location `replicator.yaml` is copied to

## [0.8.1] - Dec 27, 2018
* Updated Artifactory version to 6.6.1

## [0.8.0] - Dec 20, 2018
* Updated Artifactory version to 6.6.0

## [0.7.17] - Dec 17, 2018
* Updated Artifactory version to 6.5.13

## [0.7.16] - Dec 12, 2018
* Fix documentation about Artifactory license setup using secret

## [0.7.15] - Dec 9, 2018
* AWS S3 add `roleName` for using IAM role

## [0.7.14] - Dec 6, 2018
* AWS S3 `identity` and `credential` are now added only if have a value to allow using IAM role

## [0.7.13] - Dec 5, 2018
* Remove Distribution certificates creation.

## [0.7.12] - Dec 2, 2018
* Remove Java option "-Dartifactory.locking.provider.type=db". This is already the default setting.

## [0.7.11] - Nov 30, 2018
* Updated Artifactory version to 6.5.9

## [0.7.10] - Nov 29, 2018
* Fixed the volumeMount for the replicator.yaml

## [0.7.9] - Nov 29, 2018
* Optionally include primary node into poddisruptionbudget

## [0.7.8] - Nov 29, 2018
* Updated postgresql version to 9.6.11

## [0.7.7] - Nov 27, 2018
* Updated Artifactory version to 6.5.8

## [0.7.6] - Nov 18, 2018
* Added support for configMap to use custom Reverse Proxy Configuration with Nginx

## [0.7.5] - Nov 14, 2018
* Updated Artifactory version to 6.5.3

## [0.7.4] - Nov 13, 2018
* Allow pod anti-affinity settings to include primary node

## [0.7.3] - Nov 12, 2018
* Support artifactory.preStartCommand for running command before entrypoint starts

## [0.7.2] - Nov 7, 2018
* Support database.url parameter (DB_URL)

## [0.7.1] - Oct 29, 2018
* Change probes port to 8040 (so they will not be blocked when all tomcat threads on 8081 are exhausted)

## [0.7.0] - Oct 28, 2018
* Update postgresql chart to version 0.9.5 to be able and use `postgresConfig` options

## [0.6.9] - Oct 23, 2018
* Fix providing external secret for database credentials

## [0.6.8] - Oct 22, 2018
* Allow user to configure externalTrafficPolicy for Loadbalancer

## [0.6.7] - Oct 22, 2018
* Updated ingress annotation support (with examples) to support docker registry v2

## [0.6.6] - Oct 21, 2018
* Updated Artifactory version to 6.5.2

## [0.6.5] - Oct 19, 2018
* Allow providing pre-existing secret containing master key
* Allow arbitrary annotations on primary and member node pods
* Enforce size limits when using local storage with `emptyDir`
* Allow `soft` or `hard` specification of member node anti-affinity
* Allow providing pre-existing secrets containing external database credentials
* Fix `s3` binary store provider to properly use the `cache-fs` provider
* Allow arbitrary properties when using the `s3` binary store provider

## [0.6.4] - Oct 18, 2018
* Updated Artifactory version to 6.5.1

## [0.6.3] - Oct 17, 2018
* Add Apache 2.0 license

## [0.6.2] - Oct 14, 2018
* Make S3 endpoint configurable (was hardcoded with `s3.amazonaws.com`)

## [0.6.1] - Oct 11, 2018
* Allows ingress default `backend` to be enabled or disabled (defaults to enabled)

## [0.6.0] - Oct 11, 2018
* Updated Artifactory version to 6.5.0

## [0.5.3] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [0.5.2] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [0.5.1] - Oct 2, 2018
* Set Artifactory to 6.4.1

## [0.5.0] - Sep 27, 2018
* Set Artifactory to 6.4.0

## [0.4.7] - Sep 26, 2018
* Add ci/test-values.yaml

## [0.4.6] - Sep 25, 2018
* Add PodDisruptionBudget for member nodes, defaulting to minAvailable of 1

## [0.4.4] - Sep 2, 2018
* Updated Artifactory version to 6.3.2

## [0.4.0] - Aug 22, 2018
* Added support to run as non root
* Updated Artifactory version to 6.2.0

## [0.3.0] - Aug 22, 2018
* Enabled RBAC Support
* Added support for PostStartCommand (To download Database JDBC connector)
* Increased postgresql max_connections
* Added support for `nginx.conf` ConfigMap
* Updated Artifactory version to 6.1.0

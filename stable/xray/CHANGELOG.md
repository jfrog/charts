# JFrog Xray Chart Changelog
All changes to this chart will be documented in this file.

## [103.47.3] - Mar 31, 2022
* Added support for custom global probes timeout
* Added env variable `XRAY_K8S_ENV` to xray server container

## [103.46.0] - Mar 23, 2022
* Updated router version to `7.36.1`
* Updated Observability version to `1.5.0`

## [103.45.0] - Mar 11, 2022
* Updated router version to `7.35.0`
* Changed dependency charts repo to `charts.jfrog.io`
* Added support for `global.nodeSelector` applies to xray pods

## [103.44.0] - Feb 15, 2022
* Updated router version to `7.32.1`
* Updated Observability version to `1.3.0`
* Added support loggers sidecars to tail a configured log
* Added silent option for curl probes

## [103.42.0] - Feb 12, 2022
* Corrected the NetworkPolicy podSelector for RabbitMQ and Postgres
* Option to skip wait-for-db init container with '--set waitForDatabase=false'
* Added support for PriorityClass
* Updated Observability version to `1.2.3`

## [103.41.0] - Feb 12, 2022
* Add more user friendly support for pod affinity and anti-affinity
* Pod anti-affinity is now enabled by default (soft rule)
* Added `ResourceQuota` and permissions for xray execution service
* Added support for custom pod annotations using `xray.annotations`
* Added support for setting `fsGroupChangePolicy`
* Add job permissions to use by execution service
* Updated Observability version to `1.2.2`
* Updated router version to `7.30.0`
* Sets the AES key used by execution server to the xray server and analysis containers
* Fix regression in affinity path and revert it to its previous path

## [103.40.0] - Dec 23, 2021
* Refactored `database-creds` secret to create only when database values are passed
* Refactored probes to replace httpGet probes with basic exec + curl
* Added new endpoints for probes `/api/v1/system/liveness` and `/api/v1/system/readiness`
* Enabled `newProbes:true` by default to use these endpoints
* Updated Observability version to `1.2.0
* Fix filebeat sidecar spool file permissions
* Added `extraSecretsPrependReleaseName` to load-definitions secret in rabbitmq subchart
* Updated filebeat sidecar container to `7.16.2`

## [103.39.0] - Dec 17, 2021
* Added `server.mailServer` and `server.indexAllBuilds` as optional fields
* Added support for HorizontalPodAutoscaler apiVersion `autoscaling/v2beta2`
* Update postgresql tag version to `13.4.0-debian-10-r39`
* Refactored `router.requiredServiceTypes` to support platform chart

## [103.37.0] - Nov 26, 2021
* Fixed incorrect permission for filebeat.yaml [GH-1521](https://github.com/jfrog/charts/issues/1521)
* Moved router.topology.local.requireqservicetypes from system.yaml to router as environment variable 
* Updated initContainerImage to `jfrog/ubi-minimal:8.5-204`
* Updated Observability version to `1.1.4`
* Updated router version to `7.28.2`

## [103.36.0] - Nov 11, 2021
* Added Observability service

## [103.35.0] - Oct 14, 2021
* Added default values cpu and memeory in initContainers
* Updated router version to `7.26.0`
* Updated (`rbac.create` and `serviceAccount.create` to false by default) for least privileges
* Fixed incorrect data type for `Values.router.serviceRegistry.insecure` in default values.yaml [GH-1514](https://github.com/jfrog/charts/pull/1514/files)
* **IMPORTANT**
* Changed init-container images from `alpine` to `ubi8/ubi-minimal`
* Fixed incorrect data type for `Values.router.serviceRegistry.insecure` in default values.yaml [GH-1514](https://github.com/jfrog/charts/pull/1514/files)

## [103.34.0] - Sep 20, 2021
* Added min kubeVersion ">= 1.14.0-0" in chart.yaml
* Update alpine tag version to `3.14.2`

## [103.32.3] - Sep 08, 2021
* Dropped NET_RAW capability for the containers
* Added support for new probes(set to false by default)
* Updated router version to `7.25.1`

## [103.30.0] - Aug 13, 2021
* Update router version to `7.24.1`
* Support global and product specific tags at the same time
* Updated readme of chart to point to wiki. Refer [Installing Xray](https://www.jfrog.com/confluence/display/JFROG/Installing+Xray)
* Added security hardening fixes
* Enabled startup probes for k8s >= 1.20.x
* Changed network policy to allow all ingress and egress traffic
* Added support for serviceRegistry insecure flag in router

## [103.29.0] - July 19, 2021
* Added support for graceful shutdown of router container on SIGTERM
* Update router version to `7.21.5`

## [103.28.1] - July 13, 2021
* Add support for custom secrets

## [103.28.0] - July 6, 2021
* Update router version to `7.21.3`
* Update alpine tag version to `3.14.0`
* Add required services for router container in systemYaml

## [103.27.0] - June 15, 2021
* Added configurable `.Values.global.versions.router` in values.yaml

## [103.26.0] - June 3, 2021
* Added rabbitmq.nameOverride support for rabbitmq password and url

## [103.25.2] - May 26, 2021
* Update router version to `7.19.4`

## [103.25.1] - May 21, 2021
* Bumping chart version to align with app version
* Fix broken support for startupProbe for k8s < 1.18.x
* Update router version to `7.18.2`
* Added support for `nameOverride` and `fullnameOverride` in values.yaml
* Fix STS name in hpa

## [8.0.0] - April 22, 2021
* **Breaking change:** 
* Increased default postgresql persistence  size to `300Gi` 
* Update postgresql tag version to `13.2.0-debian-10-r55`
* Update postgresql chart version to `10.3.18` in chart.yaml - [10.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#to-1000)
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* **IMPORTANT**
* This chart is only helm v3 compatible
* Update Xray to version `3.23.0` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.23)
* Update rabbitmq tag version to `3.8.14-debian-10-r32`
* Update router version to `7.17.5`
* Update alpine tag version to `3.13.5`

## [7.7.0] - April 6, 2021
* Update Xray to version `3.22.1`

## [7.6.1] - April 6, 2021
* Update alpine tag version to `3.13.4`

## [7.6.0] - Apr 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository

## [7.5.1] - Mar 31, 2021
* Update Xray to version `3.21.2` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.21.2)

## [7.5.0] - Mar 30, 2021
* Update Xray to version `3.21.0`
* Update router version to `7.17.2`
* Add `timeoutSeconds` to all exec probes - Please refer [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)

## [7.4.0] - Mar 24, 2021
* Update Xray to version `3.20.1`
* Update router version to `7.17.1`
* Optimized startupProbe time
* Add support for graceful shutdown

## [7.3.0] - Mar 18, 2021
* Add support to startupProbe

## [7.2.0] - Mar 12, 2021
* Update Xray to version `3.19.1`

## [7.1.1] - Mar 9, 2021
* Update Xray to version `3.18.1` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.18.1)
* Removed bintray URL references in the chart
* Update router version to `7.15.3`

## [7.1.0] - Mar 03, 2021
* Update Xray to version `3.18.0` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.18)

## [7.0.2] - Feb 18, 2021
* Update router version to `7.15.2`

## [7.0.1] - Feb 18, 2021
* Update Xray to version `3.17.4` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.17.4)

## [7.0.0] - Feb 10, 2021
* **Breaking changes:**
* Deprecation of  rabbitmq-ha chart - [Notes](https://github.com/helm/charts/tree/master/stable/rabbitmq-ha#%EF%B8%8F-deprecated---rabbitmq-high-available)
* Added RABBITMQ_MIGRATION_NOTES.md - Steps for migration of data from rabbitmq-ha to rabbitmq bitnami
* **Important:** Migration to bitnami rabbitmq should be done before upgrading to 7.x chart versions

## [6.11.0] - Feb 08, 2021
* Support for custom certificates using secrets
* **Important:** Switched docker images download from `docker.bintray.io` to `releases-docker.jfrog.io`
* Update alpine tag version to `3.13.1`
* Update Xray to version `3.17.2`
* Update router version to `7.12.6`

## [6.10.0] - Jan 25, 2021
* Update Xray to version `3.16.0` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.16)
* Added support for passing additionalSpec to xray service resource
* Removed unused variables in values.yaml

## [6.9.3] - Jan 25, 2021
* Add support for hostAliases

## [6.9.2] - Jan 13, 2021
* Update Xray to version `3.15.3` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.15.3)

## [6.9.1] - Jan 5, 2021
* Add support for creating additional kubernetes resources - [refer here](https://github.com/jfrog/log-analytics-prometheus/blob/master/helm/xray-values.yaml)
* Update router version to `7.12.4`

## [6.9.0] - Dec 31, 2020
* Update Xray to version `3.15.1` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.15.1)

## [6.8.3] - Dec 29, 2020
* Update Xray to version `3.14.3` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.14.3)

## [6.8.2] - Dec 28, 2020
* Updated Xray application sizing yamls (values-small.yaml, values-medium.yaml, values-large.yaml)

## [6.8.1] - Dec 24, 2020
* Update Xray to version `3.14.1` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.14.1)

## [6.8.0] - Dec 18, 2020
* Update Xray to version `3.14.0`

## [6.7.2] - Dec 14, 2020
* Added support for passing actualUsername in secrets

## [6.7.1] - Dec 11, 2020
* Added configurable `.Values.global.versions.xray` in values.yaml

## [6.7.0] - Dec 10, 2020
* Update postgresql tag version to `12.5.0-debian-10-r25`
* Update rabbitmq tag version to `3.8.9-debian-10-r58`
* Update rabbitmq-ha tag version to `3.8.9-alpine`

## [6.6.0] - Dec 8, 2020
* Update Xray to version `3.13.0` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.13)
* Updated chart maintainers email

## [6.5.2] - Dec 4, 2020
* **Important:** Renamed `.Values.systemYaml` to `.Values.systemYamlOverride`

## [6.5.1] - Nov 30, 2020
* Updated port namings on services and pods to allow for istio protocol discovery

## [6.5.0] - Nov 30, 2020
* Update Xray to version `3.12.0` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.12)
* Update router version to `7.11.2`
* Update alpine tag version to `3.12.1`

## [6.4.4] - Nov 20, 2020
* Support external rabbitmq credentials to come from existing secret

## [6.4.3] - Nov 16, 2020
* Support actualUsername for Azure
* Bugfix - Issue with custom image tags

## [6.4.2] - Nov 16, 2020
* Update Xray to version 3.11.2 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.11)

## [6.4.1] - Nov 10, 2020
* Pass system.yaml via external secret for advanced usecases
* Bugfix - stateful set not picking up changes to database secrets

## [6.4.0] - Nov 9, 2020
* Update Xray to version 3.11.1 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.11)
* Fix values-small,medium,large yaml files

## [6.3.0] - Nov 3, 2020
* Change stable repository location to https://charts.helm.sh/stable
* Update bitnami rabbitmq chart to 7.7.1

## [6.2.1] - Oct 23, 2020
* Update router version to `1.4.4`

## [6.2.0] - Oct 23, 2020
* Update Xray to version 3.10.3 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.10.3)

## [6.1.2] - Oct 9, 2020
* Add global support for customInitContainersBegin

## [6.1.1] - Oct 5, 2020
* Fixed broken joinkey condition
* Updated UPGRADE_NOTES.md

## [6.1.0] - Oct 1, 2020
* Update Xray to version 3.9.1

## [6.0.6] - Sep 30, 2020
* Added support for resources in init containers

## [6.0.5] - Sep 28, 2020
* Update Xray to version 3.8.8 - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.8.8)
* Added support for labels for STS and pods

## [6.0.4] - Sep 25, 2020
* Update Xray to version `3.8.7` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.8.7)
* Update filebeat version to `7.9.2`

## [6.0.3] - Sep 22, 2020
* Readme Updates

## [6.0.2] - Sep 17, 2020
* Update Xray to version `3.8.6` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.8.6)

## [6.0.1] - Sep 16, 2020
* Update Xray to version `3.8.5` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.8.5)
* Added additional rabbitmq configuration
* Added back `common.xrayVersion` in values.yaml

## [6.0.0] - Sep 2, 2020
* **Breaking change:** Changed `imagePullSecrets` value from string to list.
* **Breaking change:** Added `image.registry` and `common.xrayVersion` is changed to `image.tag` under analysis,indexer,persist,server and router sections
* Added support for global values
* Update postgresql chart version to `9.3.4`
* Updated chart maintainers in chart.yaml
* Update router version to `1.4.3`

## [5.0.0] - Aug 24, 2020
* Update Xray to version `3.8.2` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.8.2)
* Update postgresql chart version to `9.3.2` - [9.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#900)
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x's postgresql.image.tag and databaseUpgradeReady=true
* Update postgresql tag version to `12.3.0-debian-10-r71`
* Update rabbitmq tag version to `3.8.7-debian-10-r3`
* Update rabbitmq-ha tag version to `3.8.7-alpine`

## [4.2.1] - Aug 14, 2020
* Added support for external rabbitmq
* Added support for Load Definitions for rabbitmq subchart when `rabbitmq.enabled=true` . Please refer [here](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq#load-definitions)

## [4.2.0] - Aug 13, 2020
* Update Xray to version `3.8.0` - [Release Notes](https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.8)
* Update rabbitmq-ha tag version to `3.8.6-alpine`
* Update rabbitmq tag version to `3.8.6-debian-10-r1`

## [4.1.3] - Jul 28, 2020
* Add tpl to external database secrets.
* Modified `scheme`  to `xray.scheme`

## [4.1.2] - Jul 16, 2020
* Added support for `common.customSidecarContainers` to create custom sidecar containers
* Added support for `common.configMaps` to create custom configMaps
* Added README for Establishing TLS and Adding certificates. Please refer [here](https://github.com/jfrog/charts/blob/master/stable/xray/README.md#establishing-tls-and-adding-certificates)
* Update router version to `1.4.2`

## [4.1.1] - Jul 10, 2020
* Move some postgresql values to where they should be according to the subchart.

## [4.1.0] - Jul 9, 2020
* Update Xray to version `3.6.2` - https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.6.2
* Update rabbitmq-ha tag version to 3.8.5-alpine
* **IMPORTANT**
* Added ChartCenter Helm repository in README

## [4.0.1] - Jul 3, 2020
* Added compatability to support latest 7.x rabbitmq subchart when `rabbitmq.enabled=true`
* Update RabbitMQ chart to v7.4.3
* **IMPORTANT**
* RabbitMQ 7.x chart is [not compatible](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq#to-700) with previous rabbitmq 6.x chart in Xray 3.x chart
* Please refer [here](https://github.com/jfrog/charts/blob/master/stable/xray/README.md#special-upgrade-notes) for upgrade notes

## [4.0.0] - Jun 26, 2020
* Update postgresql tag version to `10.13.0-debian-10-r38`
* Update alpine tag version to `3.12`
* Update rabbitmq tag version to 3.8.5-debian-10-r14
* Update RabbitMQ chart to v7.3.3
* Update RabbitMQ-HA chart to v1.46.4
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass postgresql.image.tag=9.6.18-debian-10-r7 and databaseUpgradeReady=true

## [3.5.1] - Jun 25, 2020
* Added prestartcommand to router container to match same mechanism in all other xray containers 

## [3.5.0] - Jun 22, 2020
* Update Xray to version `3.5.2` - https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.5.2
* Update alpine to version `3.12`

## [3.4.2] - Jun 13, 2020
* Adding tpl to customVolumeMounts
* Fix `replicaCount` in README.md

## [3.4.1] - Jun 12, 2020
* Fix broken customVolumeMounts

## [3.4.0] - Jun 1, 2020
* Update Xray to version `3.4.0` - https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.4
* Added Upgrade Notes in README for 3.x upgrades - https://github.com/jfrog/charts/blob/master/stable/mission-control/README.md#special-upgrade-notes
* Update router version to `1.4.0`
* Update postgresql tag version to `9.6.18-debian-10-r7`
* Added tpl to support external database secrets values
* Added custom volumes/volumesMounts under `common`
* Removed custom volumes from each specific service
* Fixes Broken upgrades of charts - use `kubectl delete statefulsets <old_statefulset_xray_name>` and run helm upgrade

## [3.3.2] - May 20, 2020
* Skip warning in NOTES if `xray.masterKeySecretName` is set

## [3.3.1] - May 01, 2020
* Adding tpl to values to support jfrogUrl

## [3.3.0] - Apr 28, 2020
* Update Xray to version `3.3.0` - https://www.jfrog.com/confluence/display/JFROG/Xray+Release+Notes#XrayReleaseNotes-Xray3.3

## [3.2.4] - Apr 20, 2020
* Adding tpl to xray-statefulset for JF_SHARED_PASSWORD

## [3.2.3] - Apr 15, 2020
* Support existingsecrets for rabbitmq/rabbitmq-ha passwords
* Bump router version to `1.3.0`
* Bump postgresql tag version to `9.6.17-debian-10-r72` in values.yaml

## [3.2.2] - Apr 15, 2020
* Fix broken rabbitmq support when `rabbitmq.enabled=true`

## [3.2.1] - Apr 14, 2020
* customInitContainer identation template fix

## [3.2.0] - Apr 13, 2020
* Bump RabbitMQ chart to v6.25.2
* Bump RabbitMQ-HA chart to v1.44.2

## [3.1.1] - April 13, 2020
* Updated helm v3 commands  

## [3.1.0] - April 10, 2020
* Use dependency charts from `https://charts.bitnami.com/bitnami`
* Bump postgresql chart version to `8.7.3` in requirements.yaml

## [3.0.28] - April 8, 2020
* Support database credentials as secrets

## [3.0.27] - April 2, 2020
* Support masterKey and joinKey as secrets

## [3.0.26] - Mar 31, 2020
* Update Xray to version `3.2.3`
* Bump router to version `1.2.1`

## [3.0.25] - Mar 31, 2020
* README fixes

## [3.0.24] - Mar 27, 2020
* Add support for masterKey as secret

## [3.0.23] - Mar 23, 2020
* Use `postgresqlExtendedConf` for setting custom PostgreSQL configuration (instead of `postgresqlConfiguration`)

## [3.0.22] - Mar 17, 2020
* Changed all single quotes to double quotes in values files

## [3.0.21] - Mar 12, 2020
* Fix for xray pvc

## [3.0.20] - Mar 11, 2020
* Unified charts public release

## [3.0.19] - Mar 9, 2020
* Cleanup `ingress` code + fixes

## [3.0.18] - Mar 9, 2020
* Add default `joinKey` value

## [3.0.17] - Mar 6, 2020
* Cleanup of not needed values
* Bump PostgreSQL chart to v8.4.1
* Bump RabbitMQ chart to v6.18.1
* Bump RabbitMQ-HA chart to v1.41.0

## [3.0.16] - Mar 4, 2020
* Add support for  disabling `consoleLog`  in `system.yaml` file

## [3.0.15] - Feb 28, 2020
* Fix reference of incorrect key to set external database url from documentation

## [3.0.14] - Feb 27, 2020
* Add an annotation with the checksum of the `system.yaml` file to make sure the pods restart after a configuration change

## [3.0.13] - Feb 26, 2020
* Update Xray to version `3.2.0` 

## [3.0.12] - Feb 24, 2020
* Update Xray to version `3.0.1`

## [1.3.8] - Feb 18, 2020
* Update Xray version to 2.11.4

## [1.3.7] - Feb 13, 2020
* Fix Xray README `ingerss.additionalRules` description

## [1.3.6] - Feb 11, 2020
* Add support for `preStartCommand`

## [1.3.5] - Feb 2, 2020
* Add a comment stating that it is recommended to use external databases with a static password for production installations

## [1.3.4] - Jan 30, 2020
* Add the option to configure resources for the logger containers

## [1.3.3] - Dec 31, 2019
* Update Xray version to 2.11.3

## [1.3.2] - Dec 23, 2019
* Mark empty map values with `{}`

## [1.3.1] - Dec 1, 2019
* Added custom volume mounts to the server stateful set
* Added custom annotations to the server, indexer, analysis, and persist stateful sets

## [1.3.0] - Dec 3, 2019
* Update Xray version to 2.11.0

## [1.2.9] - Nov 24, 2019
* Fix the Xray probes path

## [1.2.8] - Nov 21, 2019
* Make the Xray probes customisable 

## [1.2.7] - Nov 21, 2019
* Prevent probes failing on 403 (Forbidden) - fixes

## [1.2.6] - Nov 20, 2019
* Prevent probes failing on 403 (Forbidden)

## [1.2.5] - Nov 20, 2019
* Update Xray logo

## [1.2.4] - Nov 7, 2019
* Update Xray version to 2.10.7

## [1.2.3] - Oct 28, 2019
* Update Xray version to 2.10.5

## [1.2.2] - Oct 26, 2019
* Update Xray version to 2.10.4

## [1.2.1] - Oct 7, 2019
* Update Xray version to 2.10.1

## [1.2.0] - Oct 3, 2019
* Update Xray version to 2.10.0

## [1.1.1] - Sep 26, 2019
* Add support for running custom init containers before the predefined init containers using `common.customInitContainersBegin` 

## [1.1.0] - Sep 3, 2019
* Update Xray version to 2.9.0

## [1.0.5] - Aug 13, 2019
* Add the option to provide a precreated secret for XRAY_MASTER_KEY

## [1.0.4] - Aug 11, 2019
* Add information about Xray ingress additionalRules

## [1.0.3] - Jul 22, 2019
* Change Ingress API to be compatible with recent kubernetes versions

## [1.0.2] - Jul 15, 2019
* Add the option to provide ingress additional rules

## [1.0.1] - Jul 15, 2019
* Updated README.md to the new defaults.

## [1.0.0] - Jul 9, 2019
* Set default server and indexer services persistence to `true`.
* **IMPORTANT:**
  * To upgrade from a previous Xray deployment, you have to pass the `--force` flag to the `helm upgrade` command.
  * This is mandatory to force the change services persistence to `true`.
  * This change will recreate the server and indexer pods!
  * **NOTE:** Don't forget to pass the DBs passwords to the `helm upgrade` if these were auto generated. See [README.md](README.md) for details in the **Upgrade** section.

## [0.12.17] - Jul 1, 2019
* Update Xray version to 2.8.9

## [0.12.16] - June 25, 2019
* Update Xray version to 2.8.8

## [0.12.15] - June 24, 2019
* Update chart maintainers

## [0.12.14] - June 23, 2019
* Add values files for small, medium and large installations

## [0.12.13] - June 20, 2019
* Document the mongoDB resources values suggestion
* Fix xray-server service annotation

## [0.12.12] - June 17, 2019
* Optional support for PostgreSQL with TLS

## [0.12.11] - June 7, 2019
* Update Xray version to 2.8.7
* Add persistence to Server and Indexer

## [0.12.10] - May 28, 2019
* Update Xray version to 2.8.6

## [0.12.9] - May 24, 2019
* Update stateful set api and add serviceName spec

## [0.12.8] - May 20, 2019
* Fix missing logger image tag

## [0.12.7] - Apr 16, 2019
* Updated Xray version to 2.8.3

## [0.12.6] - Apr 15, 2019
* Updated Xray version to 2.8.2

## [0.12.5] - May 12, 2019
* Updated rabbitmq-ha chart version to 1.26.0

## [0.12.4] - Apr 15, 2019
* Simplify handling connection strings setup in `xray_config.yaml` to better support ampersand in external connection strings
* **IMPORTANT:** If using an external connection string for PostgreSQL or MongoDB, **do not escape** the ampersand with `\`

## [0.12.3] - Apr 15, 2019
* Move `skipEntLicCheckForCloud: true` config to be part of default Xray config

## [0.12.2] - Apr 10, 2019
* Added support for customizing the xray_config.yaml file using a configmap 

## [0.12.1] - Apr 9, 2019
* Added Xray server service annotations 
  
## [0.12.0] - Apr 9, 2019
* Updated Xray version to 2.8.0

## [0.11.2] - Apr 7, 2019
* Add network policy support

## [0.11.1] - Mar 26, 2019
* Add information about upgrading Xray with auto-generated postgres password

## [0.11.0] - Mar 26, 2019
* Switched to StatefulSets to preserve micro-service Ids

## [0.10.5] - Mar 18, 2019
* Added label selector for Xray ingress

## [0.10.4] - March 15, 2019
* Revert securityContext change that was causing issues

## [0.10.3] - March 13, 2019
* Move securityContext to container level

## [0.10.2] - March 12, 2019
* Updated Xray version to 2.7.3

## [0.10.1] - March 10, 2019
* Updated values.yaml added an important comment for the MongoDB requirements.

## [0.10.0] - Mar 3, 2019
* Support loggers sidecars to tail a configured log

## [0.9.0] - Feb 14, 2019
* Updated Xray version to 2.7.0

## [0.8.5] - Feb 11, 2019
* Add an option to set the indexAllBuilds configuration option in order to index all the builds in artifactory

## [0.8.4] - Feb 6, 2019
* Updated Postgres version to 9.6.11

## [0.8.3] - Feb 4, 2019
* Updated Xray version to 2.6.3

## [0.8.2] - Jan 24, 2019
* Added missing documentation about using `mongodb.enabled=false` when using external MongoDB

## [0.8.1] - Jan 22, 2019
* Added support for `common.customInitContainers` to create custom init containers

## [0.8.0] - Jan 1, 2019
* Updated Xray version to 2.6.0

## [0.7.8] - Dec 18, 2018
* Fix for 0.7.7 (Improve server health probes to support GKE ingress controller. Fixes https://github.com/jfrog/charts/issues/149)

## [0.7.7] - Dec 18, 2018
* Improve server health probes to support GKE ingress controller. Fixes https://github.com/jfrog/charts/issues/149

## [0.7.6] - Dec 11, 2018
* Using secret for external databases. Fixes https://github.com/jfrog/charts/issues/73

## [0.7.5] - Nov 14, 2018
* Fix bad example in [README.md]. Fixes https://github.com/jfrog/charts/issues/127.

## [0.7.4] - Nov 14, 2018
* Fix indent of `nodeSelector`, `affinity` and `tolerations` in the templates

## [0.7.3] - Nov 11, 2018
* Updated Xray version to 2.4.6

## [0.7.2] - Nov 4, 2018
* Replace POSTGRESS_ with POSTGRES_ (remove double S)

## [0.7.1] - Oct 30, 2018
* Updated Xray version to 2.4.2

## [0.7.0] - Oct 29, 2018
* Update postgresql chart to version 0.9.5 to be able and use `postgresConfig` options

## [0.6.3] - Oct 17, 2018
* Add Apache 2.0 license

## [0.6.2] - Oct 16, 2018
* Updated Xray version to 2.4.1

## [0.6.1] - Oct 11, 2018
* Allows ingress default `backend` to be enabled or disabled (defaults to enabled)
* Allows rabbitmq to be used instead of rabbitmq-ha by settings rabbitmq-ha.enabled: false and rabbitmq.enabled: true

## [0.6.0] - Oct 11, 2018
* Updated Xray version to 2.4.0

## [0.5.6] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [0.5.5] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [0.5.4] - Sep 30, 2018
* Add pods nodeSelector, affinity and tolerations

## [0.5.3] - Sep 26, 2018
* Updated Xray version to 2.3.3

## [0.5.1] - Sep 13, 2018
* Per service replica count

## [0.5.0] - Sep 3, 2018
* New RabbitMQ HA helm chart version 1.9.1
* Updated Xray version to 2.3.2

## [0.4.1] - Aug 22, 2018
* Updated Xray version to 2.3.0

## [0.4.0] - Aug 22, 2018
* Enabled RBAC support
* Added ingress support
* Updated Xray version to 2.2.4

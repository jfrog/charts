# JFrog Distribution Chart Changelog
All changes to this project chart be documented in this file.

## [102.27.1] - Oct 30, 2024
* Updated redis multi-arch tag version to 7.2.5-debian-12-r6

## [102.28.2] - Oct 02, 2024
* Adding distribution service with http-router port [GH-1872](https://github.com/jfrog/charts/pull/1872)

## [102.26.0] - June 20, 2024
* Fix the indentation of the commented-out sections in the values.yaml file
* Fixed #adding colon in image registry which breaks deployment [GH-1892](https://github.com/jfrog/charts/pull/1892)
* Fixed sizing file names

## [102.25.0] - May 16, 2024
* Update postgresql tag version to `15.6.0-debian-12-r5`
* Fixed an issue to generate unified secret to support distribution fullname [GH-1882](https://github.com/jfrog/charts/issues/1882)
* Fixed an issue template render on loggers [GH-1883](https://github.com/jfrog/charts/issues/1883)
* Added `.Values.distribution.unifiedSecretPrependReleaseName` for unified secret name as fullname release name

## [102.24.0] - Mar 27, 2024
* Added image section for `initContainers` instead of `initContainerImage`
* Renamed `distribution.image.imagePullPolicy` to `distribution.image.pullPolicy`
* Renamed `router.image.imagePullPolicy` to `router.image.pullPolicy`
* Renamed `observability.image.imagePullPolicy` to `observability.image.pullPolicy`
* Removed loggers.image section
* Added support for `global.verisons.initContainers` to override `initContainers.image.tag`
* Fixed an issue with extraSystemYaml merge

## [102.23.0] - Feb 15, 2024
* **IMPORTANT**
* Added `unifiedSecretInstallation` flag which enables single unified secret holding all internal (chart) secrets to `true` by default
* **Important change:**
* Update postgresql tag version to `15.2.0-debian-11-r23`
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default bundles PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x/13.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* Added support for distribution on openshift by setting `podSecurityContext` and `containerSecurityContext` to false
* **IMPORTANT**
* Renamed `common.uid` to `podSecurityContext.runAsUser`
* Renamed `common.gid` to `podSecurityContext.runAsGroup` and `podSecurityContext.fsGroup`
* Renamed `common.fsGroupChangePolicy` to `podSecurityContext.fsGroupChangePolicy`
* Added `redis.containerSecurityContext` to support openshift
* Renamed `redis.uid` to `redis.containerSecurityContext.runAsUser`
* Updated README.md to create a namespace using `--create-namespace` as part of helm install
* Updated redis multi-arch tag version to 7.2.4-debian-11-r5
* Refactored systemYaml configuration (moved to files/system.yaml instead of key in values.yaml).
* Added ability to provide `extraSystemYaml` configuration in values.yaml which will merge with the existing system yaml when `systemYamlOverride` is not given.
* Added IPV4/IPV6 Dualstack flag support for Distribution chart

## [102.22.0] - Dec 22, 2023
* Added recommended sizing configurations under sizing directory, please refer [here](README.md/#apply-sizing-configurations-to-the-chart)

## [102.21.0] - Nov 27, 2023
* Fixed - StatefulSet pod annotations changed from range to toYaml [GH-1828](https://github.com/jfrog/charts/issues/1828)
* Removed default hardcoded javaOpts `-Xms2g -Xmx4g` from distribution.sh file
* **IMPORTANT**
* Added min kubeVersion ">= 1.19.0-0" in chart.yaml

## [102.20.1] - Sep 18, 2023
* Reverted - Enabled `unifiedSecretInstallation` by default [GH-1819](https://github.com/jfrog/charts/issues/1819)
* Added NewRelic APM agent integration

## [102.20.0] - Aug 29, 2023
* Updated redis version tag to `7.2.0-debian-11-r2`
* Enabled `unifiedSecretInstallation` by default

## [102.19.1] - Aug 04, 2023
* Changed selectors in ServiceMonitor object to empty values

## [102.19.0] - Jun 12, 2023
* Updated postgresql multi-arch tag version to `13.10.0-debian-11-r14`
* Updated redis multi-arch tag version to `7.0.11-debian-11-r19`

## [102.18.0] - Mar 02, 2023
* Updated initContainerImage and logger image to `ubi9/ubi-minimal:9.1.0.1793`

## [102.17.0] - Jan 30, 2023
* Updated jfrogUrl text path to copy
* Updated initContainerImage and logger image to `ubi9/ubi-minimal:9.1.0.1760`

## [102.16.0] - Jan 16, 2023
* Removed `newProbes.enabled`, default to new probes
* Added support for annotations for distribution statefulset [GH-1665](https://github.com/jfrog/charts/pull/1665)
* Added topologySpreadConstraints to distribution pods
* Updated redis version tag to `7.0.6-debian-11-r0`
* Updated postgresql tag version to `13.9.0-debian-11-r11`
* Updated initContainerImage and logger image to `ubi8/ubi-minimal:8.7.1049`

## [102.15.0] - Aug 25, 2022
* Updated router version to `7.45.0`
* Added flag `distribution.schedulerName` to set for the pods the value of schedulerName field [GH-1606](https://github.com/jfrog/charts/issues/1606)
* Updated Observability version to `1.9.3`
* Added support for lifecycle hooks for all containers
* Updated logger Image to `ubi8/ubi-minimal:8.6-902`

## [102.14.0] - Aug 25, 2022
* Updated Observability version to `1.9.2`
* Use an alternate command for `find` to copy custom certificates
* Updated router version to `7.42.0`
* Increased distribution redis container probes timeout [GH-1655](https://github.com/jfrog/charts/issues/1655)
* Updated initContainerImage to `ubi8/ubi-minimal:8.6-854`
* Added support to truncate (> 63 chars) for unifiedCustomSecretVolumeName

## [102.13.0] - Apr 29, 2022
* Fixed loggers sidecars to tail a configured log
* Added silent option for curl probes
* Changed dependency charts repo to `charts.jfrog.io`
* Added support for `global.nodeSelector` applies to distribution pods
* Added support for custom global probes timeout
* Reduce startupProbe `initialDelaySeconds`
* Align all liveness and readiness probes failureThreshold to `5` seconds
* Added new flag `unifiedSecretInstallation` to enables single unified secret holding all the distribution secrets
* Updated router version to `7.38.0`
* Updated Observability version to `1.6.1`

## [102.12.0] - Feb 14, 2022
* Refactored `database-creds` secret to create only when database values are passed
* Refactored probes to replace httpGet probes with basic exec + curl
* Added new endpoints for probes `/api/v1/system/liveness` and `/api/v1/system/readiness`
* Enabled `newProbes:true` by default to use these endpoints
* Fix filebeat sidecar spool file permissions
* Updated filebeat sidecar container to `7.16.2`
* Add more user friendly support for pod affinity and anti-affinity
* Pod anti-affinity is now enabled by default (soft rule)
* Added support for custom pod annotations using `distribution.annotations`
* Updated NOTES.txt to fix improper warnings
* Added support for setting `fsGroupChangePolicy`
* Option to skip wait-for-db init container with '--set waitForDatabase=false'
* Added support for PriorityClass
* Added support to disable persistence for redis data
* Updated router version to `7.32.1`
* Updated Observability version to `1.3.0`

## [102.11.0] - Dec 17, 2021
* Updated (`rbac.create` and `serviceAccount.create` to false by default) for least privileges
* Fixed incorrect data type for `Values.router.serviceRegistry.insecure` in default values.yaml [GH-1514](https://github.com/jfrog/charts/pull/1514/files)
* **IMPORTANT**
* Fixed chart values to use curl instead of wget [GH-1529](https://github.com/jfrog/charts/issues/1529)
* Fixed incorrect permission for filebeat.yaml
* Moved router.topology.local.requireqservicetypes from system.yaml to router as environment variable
* Updated initContainerImage to `jfrog/ubi-minimal:8.5-204`
* Update redis version tag to `6.2.6-debian-10-r43`
* Added Observability service
* Add support custom labels using `distribution.labels`
* Updated router version to `7.28.2`
* Update postgresql tag version to `13.4.0-debian-10-r39`
* Refactored `router.requiredServiceTypes` to support platform chart

## [102.10.0] - Sep 24, 2021
* Updated readme of chart to point to wiki. Refer [Installing Distribution](https://www.jfrog.com/confluence/display/JFROG/Installing+Distribution)
* Added security hardening fixes
* Enabled startup probes for k8s >= 1.20.x
* Changed network policy to allow all ingress and egress traffic
* Added support for serviceRegistry insecure flag in router
* Dropped NET_RAW capability for the containers
* Added support for new probes(set to false by default)
* Updated router version to `7.25.1`
* Added min kubeVersion ">= 1.14.0-0" in chart.yaml
* Update alpine tag version to `3.14.2`
* Update busybox tag version to `1.33.1`
* Added default values cpu and memeory in initContainers

## [102.9.0] - Aug 2, 2021
* Added support for `common.preStartCommand`
* Added support for graceful shutdown of router container on SIGTERM
* Update router version to `7.21.5`
* Support global and product specific tags at the same time

## [102.8.3] - July 13, 2021
* Add support for custom secrets

## [102.8.2] - July 6, 2021
* Update router version to `7.21.3`
* Update alpine tag version to `3.14.0`
* Add required services for router container in systemYaml

## [102.8.1] - June 22, 2021
* Bumping chart version to align with app version
* **Breaking change:**
* Update postgresql tag version to `13.2.0-debian-10-r55`
* Update postgresql chart version to `10.3.18` in chart.yaml - [10.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#to-1000)
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x's postgresql.image.tag and databaseUpgradeReady=true
* **IMPORTANT**
* This chart is only helm v3 compatible
* Removed distributor service
* Increased CPU and memory limits for the Distribution service
* Update redis version tag to `6.2.1-debian-10-r9`
* Update router version to `7.19.8`
* Fix broken support for startupProbe for k8s < 1.18.x
* Added support for `nameOverride` and `fullnameOverride` in values.yaml
* Added configurable `.Values.global.versions.router` in values.yaml

## [7.7.1] - April 6, 2021
* Update alpine tag version to `3.13.4`

## [7.7.0] - Apr 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository

## [7.6.1] - Mar 30, 2021
* Update router version to `7.17.2`
* Add `timeoutSeconds` to all exec probes - Please refer [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)

## [7.6.0] - Mar 22, 2021
* Update Distribution to version `2.7.1`
* Update router version to `7.17.1`
* Add support for graceful shutdown
* Optimized startupProbe time

## [7.5.0] - Mar 18, 2021
* Add support to startupProbe

## [7.4.3] - Mar 9, 2021
* Removed bintray URL references in the chart
* Update router version to `7.15.3`

## [7.4.2] - Feb 25, 2021
* Update Distribution to version `2.6.1` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.6.1)

## [7.4.1] - Feb 19, 2021
* Update router version to `7.15.2`
* Update busybox tag version to `1.32.1`

## [7.4.0] - Feb 08, 2021
* Support for custom certificates using secrets 
* **Important:** Switched docker images download from `docker.bintray.io` to `releases-docker.jfrog.io`
* Update alpine tag version to `3.13.1`
* Update router version to `7.12.6`

## [7.3.2] - Jan 27, 2021
* Update router version to `7.12.4`

## [7.3.1] - Jan 25, 2021
* Add support for hostAliases

## [7.3.0] - Jan 13, 2021
* Update Distribution to version `2.6.0` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.6)

## [7.2.3] - Jan 8, 2021
* Add support for creating additional kubernetes resources

## [7.2.2] - Dec 22, 2020
* Update Distribution to version `2.5.4` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.5)

## [7.2.1] - Dec 11, 2020
* Added configurable `.Values.global.versions.distribution` in values.yaml

## [7.2.0] - Dec 10, 2020
* Update postgresql tag version to `12.5.0-debian-10-r25`
* Update redis tag version to `6.0.9-debian-10-r39`
* Update alpine tag version to `3.12.1`

## [7.1.7] - Dec 8, 2020
* Update Distribution to version `2.5.3` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.5)
* Updated chart maintainers email

## [7.1.6] - Dec 4, 2020
* **Important:** Renamed `.Values.systemYaml` to `.Values.systemYamlOverride`

## [7.1.5] - Dec 3, 2020
* Updated port namings on services and pods to allow for istio protocol discovery

## [7.1.4] - Nov 16, 2020
* Update Distribution to version `2.5.2` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.5.2)

## [7.1.3] - Oct 29, 2020
* Pass system.yaml via external secret for advanced usecases
* Bugfix - stateful set not picking up changes to database secrets

## [7.1.2] - Oct 23, 2020
* Update router version to `1.4.4`

## [7.1.1] - Oct 9, 2020
* Update Distribution to version `2.5.1` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.5.1)
* Add support for customInitContainersBegin

## [7.1.0] - Sep 30, 2020
* Update Distribution to version `2.5.0` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.5)
* Added support for resources in init containers
* Added upgrade notes for 4.x to 5.x and above chart versions

## [7.0.2] - Sep 25, 2020
* Update filebeat version to 7.9.2

## [7.0.1] - Sep 22, 2020
* Readme updates

## [7.0.0] - Aug 28, 2020
* **Breaking change:** Changed `imagePullSecrets` from string to list.
* **Breaking change:** Added `image.registry` and changed `image.version` to `image.tag` for docker images
* Added support for global values
* Updated maintainers in chart.yaml
* Update postgresql tag version to `12.3.0-debian-10-r71`
* Update redis tag version to `6.0.6-debian-10-r12`
* Update router version to `1.4.3`
* Update postgresql chart version to `9.3.4` in requirements.yaml - [9.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#900)
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x or 10.x's postgresql.image.tag and databaseUpgradeReady=true

## [6.1.4] - Jul 29, 2020
* Added tpl support for resolving jfrogUrl

## [6.1.3] - Jul 27, 2020
* Update Distribution to version `2.4.1` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Distribution+Release+Notes#DistributionReleaseNotes-Distribution2.4.1)

## [6.1.2] - Jul 20, 2020
* Added support for `common.customSidecarContainers` to create custom sidecar containers
* Added support for `common.configMaps` to create custom configMaps
* Moved customInitContainers under `common`
* Added README for Establishing TLS and Adding certificates. Please refer [here](https://github.com/jfrog/charts/blob/master/stable/distribution/README.md#establishing-tls-and-adding-certificates)
* Update router version to `1.4.2`

## [6.1.1] - Jul 13, 2020
* Added migration step for distribution 1.x to 2.x Appverison

## [6.1.0] - Jul 7, 2020
* Update Distribution version 2.4.0
* **IMPORTANT**
* Added ChartCenter Helm repository in README.

## [6.0.0] - Jun 26, 2020
* Update postgresql tag version to `10.13.0-debian-10-r38`
* Update alpine tag version to `3.12`
* Update busybox tag version to `1.31.1`
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass postgresql.image.tag=9.6.18-debian-10-r7 and databaseUpgradeReady=true

## [5.2.4] -  Jun 21, 2020
* Make the readiness and liveness probes configurable

## [5.2.3] -  Jun 12, 2020
* Added support for javaopts for distrubutor and distribution via systemyaml

## [5.2.2] -  Jun 11, 2020
* Added Upgrade Notes in README for 2.x upgrades - https://github.com/jfrog/charts/blob/master/stable/distribution/README.md#special-upgrade-notes

## [5.2.1] -  Jun 1, 2020
* Fixes Broken upgrades of charts - use `kubectl delete statefulsets <old_statefulset_distribution_name>` and run helm upgrade
* Readme fixes

## [5.2.0] -  May 27, 2020
* Update Distribution version 2.3.0
* Update router version to `1.4.0`
* Update redis tag version to `5.0.9-debian-10-r31`
* Update postgresql tag version to `9.6.18-debian-10-r7`
* Update alpine version to `3.11`

## [5.1.3] - April 24, 2020
* Add support to db existing secrets
* Fix broken support if `postgresql.postgresqlPassword` not explicitly set

## [5.1.2] - April 20, 2020
* Bump router version to `1.3.0`
* Fix broken support if `redis.password` not explicitly set
* Bump postgresql tag version to `9.6.17-debian-10-r72` in values.yaml
* Add support for existingSecret for redis-password

## [5.1.1] - April 10, 2020
* Update README with helm v3 commands 

## [5.1.0] - April 10, 2020
* Use dependency charts from `https://charts.bitnami.com/bitnami`
* Bump postgresql chart version to `8.7.3` in requirements.yaml
* Bump postgresql tag version to `9.6.17-debian-10-r21` in values.yaml

## [5.0.20] - April 2, 2020
* Support masterKey and joinKey as secrets

## [5.0.19] - Mar 30, 2020
* Readme fixes

## [5.0.18] - Mar 23, 2020
* Use `postgresqlExtendedConf` for setting custom PostgreSQL configuration (instead of `postgresqlConfiguration`)

## [5.0.17] - Mar 17, 2020
* Changed all single quotes to double quotes in values files

## [5.0.16] - Mar 11, 2020
* Unified charts public release

## [5.0.15] - Mar 9, 2020
* Removed unused `ingress` code + fixes

## [5.0.14] - Mar 4, 2020
* Add support for  disabling `consoleLog`  in `system.yaml` file

## [5.0.13] - Feb 27, 2020
* Add an annotation with the checksum of the `system.yaml` file to make sure the pods restart after a configuration change

## [5.0.12] - Feb 26, 2020
* Update Distribution to version `2.2.0` 

## [5.0.11] - Feb 24, 2020
* Update Distribution to version `2.0.3` 

## [3.6.0] - Feb 16, 2020
* Add support for distributor `customVolumeMounts` and move `customVolumes` to `common`

## [3.5.4] - Feb 13, 2020
* Add support for `ingress.additionalRules` and `ingress.defaultBackend`

## [3.5.3] - Feb 11, 2020
* Add support for `preStartCommand`, `customVolumes` and `customVolumeMounts`

## [3.5.2] - Feb 2, 2020
* Add a comment stating that it is recommended to use an external PostgreSQL with a static password for production installations

## [3.5.1] - Jan 30, 2020
* Add the option to configure resources for the logger containers

## [3.5.0] - Jan 8, 2020
* Update Distribution version 1.8.0

## [3.4.4] - Oct 20, 2019
* Update Distribution logo

## [3.4.3] - Oct 18, 2019
* Update Distribution version 1.7.3

## [3.4.2] - Oct 6, 2019
* Update Distribution version 1.7.2

## [3.4.1] - Sep 25, 2019
* Update Distribution version 1.7.1

## [3.4.0] - Aug 19, 2019
* Update Distribution version 1.7.0

## [3.3.0] - Jul 22, 2019
* Change Ingress API to be compatible with recent kubernetes versions

## [3.2.9] - Jun 30, 2019
* Update statfulset apiVersion to apps/v1

## [3.2.8] - Jun 27, 2019
* Update Distribution version 1.6.1

## [3.2.7] - Jun 24, 2019
* Update chart maintainers

## [3.2.6] - Jun 23, 2019
* Add values files for small, medium and large installations

## [3.2.5] - May 19, 2019
* Fix missing logger image tag

## [3.2.4] - Apr 7, 2019
* Add network policy support

## [3.2.3] - Apr 1, 2019
* Add information about upgrading distribution with the auto-generated redis password

## [3.2.2] - Mar 15, 2019
* Revert securityContext change that was causing issues

## [3.2.1] - Mar 13, 2019
* Move securityContext to container level

## [3.2.0] - Mar 1, 2019
* Support loggers sidecars to tail a configured log

## [3.1.0] - Feb 18, 2019
* Update Distribution version 1.6.0

## [3.0.2] - Feb 17, 2019
* Add `component` label to missing objects

## [3.0.1] - Feb 14, 2019
* Add support for `distribution.service.loadBalancerSourceRanges` to set whitelist on load balancer

## [3.0.0] - Feb 04, 2019
* Update Distribution version 1.5.1
* Join distribution, distributor and redis to a single pod
* Distributor internal communication token generated and consumed automatically
* **UPGRADE NOTES:** For upgrading an existing deployment (pre 1.5.1), follow the following:
  * Distribution should be idle. This means not have any distributions in queue or in process
  * If in HA (replicaCount > 1)
    * Scale down **existing deployment** to 1 with `helm upgrade .... --set replicaCount=1 ....`.
    * Once upgraded and new version is running, scale back up to the original size.
    
## [2.1.2] - Jan 24, 2019
* Added support for `distribution.customInitContainers` to create custom init containers for Distribution pod

## [2.1.1] - Jan 15, 2019
* add master key as env var in Distribution

## [2.1.0] - Jan 13, 2019
* Update Distribution version 1.5.0
* Remove MongoDB completely. This means an upgrade to this version must go through version 1.4.0 (chart version 2.0.0)! 

## [2.0.0] - Dec 17, 2018
* Update Distribution version 1.4.0
* Move to using PostgreSQL as Distribution database (replace MongoDB)
* **UPGRADE NOTES:** For upgrading an existing deployment (pre 1.4.0), follow the following:
  * Distribution should be idle. This means not have any distributions in queue or in process
  * If in HA (replicaCount > 1), scale down **existing deployment** to 1 with `helm upgrade .... --set replicaCount=1 ....`
  * New Distribution must be installed with both databases: MongoDB and PostgreSQL
    * Upgrade to new version (1.4.0) with the following parameter for the upgrade process `helm upgrade .... --set mongodb.enabled=true ....`
  * Once Distribution is up - it means the migration from MongoDB to PostgreSQL is done!
  * You can deploy again without MongoDB and back to your required `replicaCount`

## [1.1.2] - Nov 14, 2018
* Fix indent of `nodeSelector`, `affinity` and `tolerations` in the templates

## [1.1.1] - Oct 17, 2018
* Add Apache 2.0 license

## [1.1.0] - Oct 14, 2018
* Upgrade MongoDB version (chart 4.3.10, app 3.6.8-debian-9)

## [1.0.6] - Oct 11, 2018
* Update Distribution version 1.3.0

## [1.0.5] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [1.0.4] - Oct 8, 2018
* Fix distribution to use mongodb credentials secret

## [1.0.3] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [1.0.2] - Sep 30, 2018
* Add pods nodeSelector, affinity and tolerations

## [1.0.1] - Sep 26, 2018
* Disable persistence for CI testing
* Enable RBAC

## [1.0.0] - Sep 17, 2018
* **NOTE:** This chart is not compatible with older versions and should not be used to upgrade them. See README for more details on upgrades
* True HA with distributor and Redis in their own StatefulSets and headless services
* Redis StatefulSet now part of the main templates
* New Redis version: 4.0.11

## [0.6.0] - Sep 6, 2018
* Change Distribution DB name to `distribution`

## [0.5.0] - Sep 2, 2018
* HA support
* Full non-root Docker images
* Updated Distribution version to 1.2.0

## [0.4.0] - Aug 22, 2018
* Enabled RBAC Support
* Changed Deployment to Statefulset for Distribution's micro services
* Updated Distribution version to 1.1.0

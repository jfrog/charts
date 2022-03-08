# JFrog Mission-Control Chart Changelog
All changes to this chart will be documented in this file.

## [104.7.16] - Sep 20, 2021
* Added missing security context in filebeat container
* Update elasticsearch version to `7.14.1`
* Added min kubeVersion ">= 1.14.0-0" in chart.yaml
* Update alpine tag version to `3.14.2`
* Update busybox tag version to `1.33.1`

## [104.7.14] - Sep 02, 2021
* Dropped NET_RAW capability for the containers
* Added support for new probes(set to false by default)
* Update elasticsearch version to `7.14.0`
* Updated router version to `7.25.1`

## [104.7.12] - Aug 25, 2021
* Added security hardening fixes
* Update router version to `7.24.1`
* Update elasticsearch version to `7.13.4`
* Enabled startup probes for k8s >= 1.20.x
* Changed network policy to allow all ingress and egress traffic
* Added support for serviceRegistry insecure flag in router
* Fixed duplicate resources Key violates YAML spec
* Added elasticsearch default java opts to `2g`
* Added support for new probes(set to false by default)

## [104.7.11] - July 22, 2021
* Added support for graceful shutdown of router container on SIGTERM
* Update router version to `7.21.5`
* Added elasticsearch.app.version to system.yaml
* Update elasticsearch version to `7.13.2`

## [104.7.10] - Aug 9, 2021
* Added support for graceful shutdown of router container on SIGTERM
* Update router version to `7.21.5`
* Added elasticsearch.app.version to system.yaml
* Update elasticsearch version to `7.13.2`
* Support global and product specific tags at the same time
* Updated readme of chart to point to wiki. Refer [Installing Mission Control](https://www.jfrog.com/confluence/display/JFROG/Installing+Mission+Control)

## [104.7.8] - July 6, 2021
* Update router version to `7.21.3`
* Update alpine tag version to `3.14.0`
* Add required services for router container in systemYaml

## [104.7.7] - June 17, 2021
* Bumping chart version to align with app version
* **Breaking change:** 
* Increased default postgresql persistence  size to `100Gi` 
* Update postgresql tag version to `13.2.0-debian-10-r55`
* Update postgresql chart version to `10.3.18` in chart.yaml - [10.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#to-1000)
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* **IMPORTANT**
* This chart is only helm v3 compatible
* Update router version to `7.19.8`
* Update alpine tag version to `3.13.5`
* Fix broken support for startupProbe for k8s < 1.18.x
* Remove `prepare-storage` init container fixes openShift issue
* Added support for `nameOverride` and `fullnameOverride` in values.yaml
* Added configurable `.Values.global.versions.router` in values.yaml
* Update elasticsearch version to `7.12.1`

## [5.8.3] - May 26, 2021
* Update mission-Control to version `4.7.4` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.7.4)

## [5.8.2] - April 15, 2021
* Update mission-Control to version `4.7.3` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.7.3)

## [5.8.1] - April 6, 2021
* Update alpine tag version to `3.13.4`

## [5.8.0] - Apr 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository

## [5.7.2] - Mar 31, 2021
* Update mission-Control to version `4.7.2` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.7.2)

## [5.7.1] - Mar 30, 2021
* Update router version to `7.17.2`
* Add `timeoutSeconds` to all exec probes - Please refer [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)

## [5.7.0] - Mar 22, 2021
* Update mission-Control to version `4.7.1`
* Update router version to `7.17.1`
* Update Elasticsearch version to `7.10.2` with Searchguard
* Add support for graceful shutdown
* Optimized startupProbe time

## [5.6.0] - Mar 18, 2021
* Add support to startupProbe

## [5.5.3] - Mar 12, 2021
* Update mission-Control to version `4.6.5` - [Release notes](https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.6.5)

## [5.5.2] - Mar 9, 2021
* Removed bintray URL references in the chart
* Update router version to `7.15.3`

## [5.5.1] - Feb 19, 2021
* Update router version to `7.15.2`
* Update busybox tag version to `1.32.1`

## [5.5.0] - Feb 08, 2021
* Support for custom certificates using secrets
* **Important:** Switched docker images download from `docker.bintray.io` to `releases-docker.jfrog.io`
* Update alpine tag version to `3.13.1`
* Update router version to `7.12.6`

## [5.4.6] - Jan 27, 2021
* Update router version to `7.12.4`

## [5.4.5] - Jan 25, 2021
* Add support for hostAliases

## [5.4.4] - Jan 18, 2021
* Update Mission Control version to 4.6.3
* Upgrade Elasticsearch version to 7.8.1 with Searchguard
* Added support for `.Values.elasticsearch.username`
* Added support for custom tls certificates for elastic searchguard
* **IMPORTANT**
* If the certificates are changed, rolling update is not possible. Scale down to one replica and do an helm upgrade

## [5.4.3] - Jan 8, 2021
* Add support for creating additional kubernetes resources

## [5.4.2] - Dec 17, 2020
* Update Mission Control version to 4.6.2

## [5.4.1] - Dec 11, 2020
* Added configurable `.Values.global.versions.missionControl` in values.yaml

## [5.4.0] - Dec 10, 2020
* Update postgresql tag version to `12.5.0-debian-10-r25`
* Updated chart maintainers email

## [5.3.4] - Dec 4, 2020
* **Important:** Renamed `.Values.systemYaml` to `.Values.systemYamlOverride`

## [5.3.3] - Dec 3, 2020
* Updated port namings on services and pods to allow for istio protocol discovery

## [5.3.2] - Nov 30, 2020
* Update router version to `7.11.5`
* Added special notes in readme for upgrading to 5.2.x and above chart versions

## [5.3.1] - Nov 30, 2020
* Update Mission Control version to 4.6.1
* Update router version to `7.11.2`

## [5.3.0] - Nov 16, 2020
* Update Mission Control version to 4.6.0
* Update alpine tag version to `3.12.1`

## [5.2.2] - Nov 10, 2020
* Pass system.yaml via external secret for advanced usecases
* Added configurable `insightServer.clients.elasticsearch.searchguard.connectionWaitTimeoutSecs` in values.yaml
* Bugfix - stateful set not picking up changes to database secrets

## [5.2.1] - Nov 9, 2020
* Expose router port 8082 for inter pod communication

## [5.2.0] - Oct 27, 2020
* Upgrade Elasticsearch version to 7.8.0 with Searchguard
* Added configurable `insightServer.clients.elasticsearch.connectionWaitTimeoutSecs` in values.yaml 
* **IMPORTANT**
* Enable Elasticsearch request via router

## [5.1.1] - Oct 24, 2020
* Update router version to `1.4.4`

## [5.1.0] - Oct 13, 2020
* **Breaking**
* Changed `insightServer.internalHttpPort` to `insightServer.internalPort`
* Add support for livenessProbe and readinessProbe for all microservices
* Updated UPGRADE_NOTES.md - Upgrading to 4.x and above charts versions

## [5.0.5] - Oct 9, 2020
* Add support for customInitContainersBegin

## [5.0.4] - Oct 1, 2020
* Added support for resources in init containers

## [5.0.3] - Sep 29, 2020
* Fix broken failure when using existing pvc

## [5.0.2] - Sep 25, 2020
* Changed insightServer.internalHttpPort to `8087`
* Changed initial replicaCount to 1 when replicacount > 1
* Update filebeat version to `7.9.2`

## [5.0.1] - Sep 22, 2020
* Readme updates

## [5.0.0] - Sep 3, 2020
* **Breaking change:** Modified `imagePullSecrets` value from string to list.
* **Breaking change:** Added `image.registry` and changed `image.version` to `image.tag` for docker images
* Added support for global values
* Updated maintainers in chart.yaml
* Update postgresql tag version to `12.3.0-debian-10-r71`
* Update router version to `1.4.3`
* Update postgresql chart version to `9.3.4` in requirements.yaml - [9.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#900)
* Removed redundant mcKey
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x or 10.x's postgresql.image.tag and databaseUpgradeReady=true

## [4.3.2] - Aug 20, 2020
* Support list of custom secrets.

## [4.3.1] - Aug 13, 2020
* Expose Elasticsearch HTTP port with the mission control service.

## [4.3.0] - Aug 12, 2020
* Update Mission Control version to 4.5.0
* **IMPORTANT**
* Removed insight executor service

## [4.2.1] - Jul 30, 2020
* Fix broken support for External elasticsearch
* Added tpl support for resolve jfrogUrl

## [4.2.0] - Jul 27, 2020
* Added support for `common.customSidecarContainers` to create custom sidecar containers.
* Added support for `common.configMaps` to create custom configMaps
* Moved customVolumes,customVolumeMounts,customInitContainers under `common`
* Added README for Establishing TLS and Adding certificates. Please refer [here](https://github.com/jfrog/charts/blob/master/stable/mission-control/README.md#establishing-tls-and-adding-certificates)
* Update router version to `1.4.2`

## [4.1.1] - Jul 20, 2020
* Updated Mission-Control Chart to add labels from values to service, pods and controller 

## [4.1.0] - Jul 10, 2020
* Move some postgresql values to where they should be according to the subchart
* **IMPORTANT**
* Added ChartCenter Helm repository in README

## [4.0.1] -  Jun 29, 2020
* Added UPGRADES_NOTES.md for upgrading to 3.x/4.x chart versions

## [4.0.0] - Jun 26, 2020
* Update postgresql tag version to `10.13.0-debian-10-r38`
* Update alpine tag version to `3.12`
* Update busybox tag version to `1.31.1`
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass postgresql.image.tag=9.6.18-debian-10-r7 and databaseUpgradeReady=true

## [3.4.7] -  Jun 17, 2020
* Added support for javaopts via systemyaml

## [3.4.6] - June 15, 2020
* Update Mission Control version to 4.4.2 - https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.4.2

## [3.4.5] - June 9, 2020
* Added support for Elasticsearch secrets 

## [3.4.4] - June 4, 2020
* Update postgresql image tag to `9.6.18-debian-10-r7`
* Added Upgrade Notes in README for 4.x upgrades - https://github.com/jfrog/charts/blob/master/stable/mission-control/README.md#special-upgrade-notes

## [3.4.3] - June 1, 2020
* Update Mission Control version to 4.4.1
* Fixes Broken upgrades of charts - use `kubectl delete statefulsets <old_statefulset_mission-control>` and run helm upgrade

## [3.4.2] - May 25, 2020
* Added ci test for image version change
* Added ci test for postgresql image tag
* Readme fixes

## [3.4.1] - May 21, 2020
* Fix image version in statefulset

## [3.4.0] - May 19, 2020
* Update Mission Control to version `4.4.0` - https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.4
* Bump router version to `1.4.0`

## [3.3.0] - May 12, 2020
* Support external database secrets
* **Breaking change:** Use single user/password for all services for both internal/external databases.

## [3.2.1] - April 26, 2020
* Added `elasticsearch.configureDockerHost` parameter to enable control over running of privileged containers (init-elasticsearch)

## [3.2.0] - Apr 21, 2020
* Upgrade Elasticsearch version to 7.6.1
* Upgrade Mission Control version to 4.3.2
* Bump postgresql tag version to `9.6.17-debian-10-r72` in values.yaml
* Bump router  version to `1.3.0`
* **NOTE:** If you have externalized elasticsearch, please upgrade your elasticsearch to 7.6.1 to work with Mission Control 4.3.x. Mission Control version 4.3.x and above is not compatible with Elasticsearch version 6.x.
* **NOTE:** Mission Control version 4.3.2 is compatible with Artifactory 7.4.1 and above. Refer Mission Control release notes for more details - https://www.jfrog.com/confluence/display/JFROG/Mission+Control+Release+Notes#MissionControlReleaseNotes-MissionControl4.3.2.

## [3.1.1] - April 13, 2020
* Update README with helm v3 commands

## [3.1.0] - April 10, 2020
* Use dependency charts from `https://charts.bitnami.com/bitnami`
* Bump postgresql chart version to `8.7.3` in requirements.yaml
* Bump postgresql tag version to `9.6.17-debian-10-r21` in values.yaml

## [3.0.23] - April 3, 2020
* Support masterKey and joinKey as secrets
* Support `masterKey` (previously `mcKey`) in values.yaml

## [3.0.22] - Mar 30, 2020
* Readme fixes

## [3.0.21] - Mar 23, 2020
* Use `postgresqlExtendedConf` for setting custom PostgreSQL configuration (instead of `postgresqlConfiguration`)

## [3.0.20] - Mar 17, 2020
* Changed all single quotes to double quotes in values files

## [3.0.19] - Mar 11, 2020
* Unified charts public release

## [3.0.18] - Mar 9, 2020
* Removed unused `ingress` code + fixes

## [3.0.17] - Mar 9, 2020
* Fix `elasticsearch` indentation  in `system.yaml` file

## [3.0.16] - Mar 4, 2020
* Add support for  disabling `consoleLog`  in `system.yaml` file
* Add support for  database secrets

## [3.0.15] - Feb 27, 2020
* Add an annotation with the checksum of the `system.yaml` file to make sure the pods restart after a configuration change

## [3.0.14] - Feb 26, 2020
* Fix path of mission-control entrypoint

## [3.0.12] - Feb 24, 2020
* Update Mission Control to version `4.2.0`

## [1.1.17] - Feb 13, 2020
* Add support for `ingress.additionalRules` and `ingress.defaultBackend`

## [1.1.16] - Feb 11, 2020
* Use a with clause for `preStartCommand`, `customVolumes` and `customVolumeMounts`

## [1.1.15] - Feb 6, 2020
* Fix init containers resources

## [1.1.14] - Feb 2, 2020
* Add a comment stating that it is recommended to use an external PostgreSQL with a static password for production installations

## [1.1.13] - Jan 30, 2020
* Add the option to configure resources for the logger containers

## [1.1.12] - Jan 22, 2020
* Add support for providing resources to the init containers and the insight container

## [1.1.11] - Jan 19, 2020
* Update Mission-Control version to 3.5.6

## [1.1.10] - Nov 21, 2019
* Support missionControl.preStartCommand for running command before entrypoint starts

## [1.1.9] - Nov 20, 2019
* Update Mission-Control logo

## [1.1.8] - Nov 12, 2019
* Add annotation options to Mission-Control service

## [1.1.7] - Nov 11, 2019
* Update Mission-Control version to 3.5.5

## [1.1.6] - Sep 23, 2019
* Update Mission-Control version to 3.5.4

## [1.1.5] - Jul 22, 2019
* Change Ingress API to be compatible with recent kubernetes versions

## [1.1.4] - Jun 24, 2019
* Update chart maintainers

## [1.1.3] - Jun 23, 2019
* Add values files for small, medium and large installations

## [1.1.2] - Jun 3, 2019
* Update Mission-Control version to 3.5.3
* Use correct key to specify UpdateStrategy
* Update apiVersion to apps/v1

## [1.1.1] - May 20, 2019
* Fix missing logger image tag

## [1.1.0] - May 10, 2019
* Added support for `missionControl.customVolumeMounts` and `missionControl.customVolumes` to create custom volume mounts

## [1.0.6] - Apr 17, 2019
* Update Mission-Control version to 3.5.2

## [1.0.5] - Apr 9, 2019
* Update Mission-Control version to 3.5.1

## [1.0.4] - Apr 7, 2019
* Add network policy support

## [1.0.3] - Apr 4, 2019
* Add information about upgrading mission-control with auto-generated postgres password

## [1.0.2] - Apr 4, 2019
* Change mission-control auto-generated DB password to update the password on every startup

## [1.0.1] - Apr 1, 2019
* Fix error of missing volume when `missionControl.persistence` is disabled

## [1.0.0] - Mar 28, 2019
* **NOTE:** This chart is not compatible with older versions and should not be used to upgrade them. See README for more details on upgrades
* Updated Mission Control version to 3.5.0
* HA support for Mission Control and elasticsearch with Statefulset
* Elasticsearch now part of Mission Control template
* New Elasticsearch (6.6.0) with searchguard plugin enabled

## [0.9.4] - Mar 26, 2019
* Add default auto-generated random password for mission control database users

## [0.9.3] - Mar 15, 2019
* Revert securityContext change that was causing issues

## [0.9.2] - Mar 14, 2019
* Move securityContext to container level

## [0.9.1] - Mar 14, 2019
* Updated Mission-Control version to 3.4.3

## [0.9.0] - Feb 28, 2019
* Support loggers sidecars to tail a configured log

## [0.8.1] - Feb 20, 2019
* Update Mission-Control Readme with new database details

## [0.8.0] - Feb 19, 2019
* Update Mission-Control version 3.4.2
* Move to using PostgreSQL as Mission-Control database (replace MongoDB)
* Move setup of database from post install hook to init container of corresponding deployment
* **NOTE:** For upgrading an existing deployment (pre 3.4.2), Mission-Control must be installed with both databases: MongoDB and PostgreSQL
* **UPGRADE NOTES:** For upgrading an existing deployment (pre 3.4.2), follow the following:
  * Pass `--set mongodb.enabled=true` to the `helm upgrade command`.
  * Mission-Control should be idle.
  * New Mission-Control must be installed with both databases: MongoDB and PostgreSQL
    * Upgrade to new version (3.4.2) with the following parameter for the upgrade process `helm upgrade .... --set mongodb.enabled=true ....`
  * Once Mission-Control is up - it means the migration from MongoDB to PostgreSQL is done!

## [0.7.3] - Jan 31, 2019
* Add 0.5G to all memory limits for java services to be higher than java xmx value

## [0.7.2] - Jan 23, 2019
* Added support for `missionControl.customInitContainers` to create custom init containers

## [0.7.1] - Dec 17, 2018
* Updated Mission-Control version to 3.3.2

## [0.7.0] - Nov 16, 2018
* Updated Mission-Control version to 3.3.0
* Remove usage of certificates for internal communication

## [0.6.0] - Oct 18, 2018
* Updated Mission-Control version to 3.2.0
* This chart version (0.6.0) cannot be used to deploy older versions of Mission Control (less than or equal to 3.1.2)

## [0.5.2] - Oct 17, 2018
* Add Apache 2.0 license

## [0.5.1] - Oct 16, 2018
* Fix #67 Set password used to generate internal certs in Mission-Control

## [0.5.0] - Oct 14, 2018
* Upgrade MongoDB version (chart 4.3.10, app 3.6.8-debian-9)

## [0.4.5] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [0.4.4] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [0.4.3] - Sep 6, 2018
* Option to set Java `Xms` and `Xmx` for Insight scheduler and executor

## [0.4.2] - Aug 23, 2018
* Updated Mission-Control version to 3.1.2

## [0.4.1] - Aug 22, 2018
* Enabled RBAC Support
* Using secrets for credentials
* Updated Mission-Control version to 3.1.1
* Changed deployment api to apps/v1beta2
* Made postInstallHook image configurable

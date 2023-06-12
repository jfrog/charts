# JFrog Pipelines Chart Changelog
All changes to this chart to be documented in this file.

## [101.38.1] - Apr 18, 2023
* Handle jfrogUrlUI if nothing is set
* Fix migration script failures on ssl enforced database

## [101.37.3] - Feb 20, 2023
* Added build badge feature for pipelines
* Added configuration to use access instead of vault to store secrets
* Retained installer metrics only for db migrations

## [101.35.0] - Feb 06, 2023
* Fixed indentation in nodepoolservice container definition

## [101.34.0] - Jan 24, 2023
* Added metrics to required init containers
* Resources in pipelines observability is not renderring as expected

## [101.33.0] - Jan 03, 2023
* Rename nodepoolManager to nodepoolservice
* Always run the nodepoolservice in both modes ( single pod and split mode)
* Aligned ingress resource with cluster's networking API
* Updated jfrogUrl text path to copy

## [101.33.0] - Dec 30, 2022
* Added readiness and liveness for the missing pods

## [101.31.0] - Dec 16, 2022
* Updated postgresql tag version to `13.9.0-debian-11-r11`
* Improve pod startup time and reduce default resources on initcontainers

## [101.29.0] - Dec 13, 2022
* Group and split services to multiple pods to support autoscaling of only required services behind a feature flag
* Made system config polling configurable from system.yaml
* Handle long release names in wait for internal api logic in split mode
* Ability to pass environment variables to specific service container
* Add support for pod labels 

## [101.28.0] - Oct 27, 2022
* Added init containers wait-for-db and create-vault-table in vault-server pod
* Added support for annotations for pipelines statefulset [GH-1665](https://github.com/jfrog/charts/pull/1665)
* Added default pipelines image for ubuntu20 arm64 build nodes
* Made baseUrlUI requirement optional in charts during install time

## [101.27.0] - Sep 28, 2022
* Added `observability` service in pipelines
* Removed `newProbes.enabled`, default to new probes
* Fixed bug for `unifiedSecretInstallation` support in observability
* Fixed stringData secret keys value issue, moving data to stringData vault.sql and postgresql-connection keys

## [101.26.0] - Aug 25, 2022
* Added flag `pipelines.schedulerName` to set for the pods the value of schedulerName field [GH-1606](https://github.com/jfrog/charts/issues/1606)
* Added config to reset log level
* Change default go runtime images to 1.19
* Added `NodePoolManager` microservice with default state as disabled

## [101.25.0] - Aug 25, 2022
* Additional fix for default path for api external url
* Fixed custom CA init container behavior
* Updated rabbitmq version to `3.9.21-debian-11-r0`
* Added support to truncate (> 63 chars) for unifiedCustomSecretVolumeName

## [101.24.2] - June 22, 2022
* Only set k8sImagePullSecret key if one is configured in values.yaml
* Use an alternate command for `find` to copy custom certificates

## [101.24.1] - June 16, 2022
* Fixes default path for api external url

## [101.24.0] - Apr 27, 2022
* Update rabbitmq chart and image to 8.31.6 and 3.9.15-debian-10-r5

## [101.23.0] - Apr 25, 2022
* Changed dependency charts repo to `charts.jfrog.io`
* Added support for `global.nodeSelector` applies to pipelines pods
* Set api external url to jfrogUrlUI when both api ingress is disabled and external api url is empty
* Added new flag "enforceNonRootNodes" to enforce non root installation
* Added support for custom global probes timeout
* Reduce startupProbe `initialDelaySeconds`
* Align all liveness and readiness probes failureThreshold to `5` seconds
* Removed newRelic support
* Added new flag `unifiedSecretInstallation` to enables single unified secret holding all the pipelines secrets

## [101.22.0] - Apr 7, 2022
* Refactored probes to replace httpGet probes with basic exec + curl
* Added new endpoints for probes `/api/v1/system/liveness` and `/api/v1/system/readiness`
* Enabled `newProbes:true` by default to use these endpoints
* Fix filebeat sidecar spool file permissions
* Updated filebeat sidecar container to `7.16.2`
* Added config for liveness and readiness new probes
* Add more user friendly support for pod affinity and anti-affinity
* Pod anti-affinity is now enabled by default (soft rule)
* Added support for custom pod annotations using `pipelines.annotations`
* Option to skip wait-for-db init container with '--set waitForDatabase=false'
* Added support for PriorityClass
* Set node 16 as default linux build image and as default node version
* Set jdk 17 as default java image
* Set go 1.17 as default go image
* Set dotnet 6 as default W19 image and as default dotnet version
* Added `logup` service under `core.services` section
* Bugfix - joinkey as a secret with joinKeySecretName
* Added `frontend` nginx microservice for micro frontends
* Fixed bug where all pipeline pods could run on the same node by adding missing labels for pipelines pods

## [101.21.0] - Dec 17, 2021
* Add support custom labels using `pipelines.labels`
* Added support for HorizontalPodAutoscaler apiVersion `autoscaling/v2beta2`
* Added metrics framework logging config and config to stream logs to stdout
* Update postgresql tag version to `13.4.0-debian-10-r39`
* Refactored `router.requiredServiceTypes` to support platform chart

## [101.20.0] - Dec 14, 2021
* Add support for Ingress Class Name in Ingress Spec [GH-1516](https://github.com/jfrog/charts/pull/1516)
* Fixed chart values to use curl instead of wget [GH-1529](https://github.com/jfrog/charts/issues/1529)
* Add installer logs to shared logs volume
* Moved router.topology.local.requireqservicetypes from system.yaml to router as environment variable
* Aligned router configuration in system.yaml
* Fixed `global.joinKeySecretName` usage
* Update Vault tag version to `1.8.6`
* Removed `jfpipwww` as a router required service

## [101.19.0] - Nov 18, 2021
* update system yaml with newer LTS build images
* **Breaking change**
* Aligned probe structure (moved probes variables under config block)
* Added support for new probes(set to false by default)
* Aligned the redis pod to use explicit service account
* Dropped NET_RAW capability for pipelines-installer
* Removing www ingress which has to be aligned with pipelines > 1.18.0
* **IMPORTANT**
* Hashicorp Vault chart replaces internal Vault
* Passing PIPELINES_NODE_ID to each pipelines microservice
* Added support for Ingress networking.k8s.io/v1/Ingress for k8s >=1.22 [GH-1487](https://github.com/jfrog/charts/pull/1487)
* Added support for postgresql external url
* Added min kubeVersion ">= 1.14.0-0" in chart.yaml
* Update alpine tag version to `3.14.2`
* Moving required local services config from env to systemyaml
* Added default values cpu and memeory in initContainers
* Added jfconnect feature flag(set to false by default)
* Remove rabbitmq ingress support.
* Perform base64 encoding for postgreqsql external url
* Added `serviceAccount.create` to toggle creation of service accounts
* Updated (`rbac.create` and `serviceAccount.create` to false by default) for least privileges
* Fixed incorrect data type for `Values.router.serviceRegistry.insecure` in default values.yaml [GH-1514](https://github.com/jfrog/charts/pull/1514/files)
* Added piplines logs configuration

## [101.18.0] - Aug 10, 2021
* Added security hardening fixes
* Added support for configuring postgresql connection pool
* Added support for insecure registry url for router
* Added support for newRelic
* Enabled startup probes for k8s >= 1.20.x

## [101.17.0] - July 27, 2021
* Support global and product specific tags at the same time
* Updated readme of chart to point to wiki. Refer [Installing Pipelines](https://www.jfrog.com/confluence/display/JFROG/Installing+Pipelines#InstallingPipelines-HelmInstallation)

## [101.16.1] - July 1, 2021
* Increase stepTimeoutMS limit

## [101.16.0] - May 25, 2021
* Added support for allowCustomNodes to allow static nodes
* Move stepTimeoutMS to align with other configurations

## [101.15.2] - May 20, 2021
* Added support for `nameOverride` and `fullnameOverride` in values.yaml

## [101.15.1] - May 12, 2021
* Bumping chart version to align with app version
* **Breaking change:**
* Increased default postgresql persistence  size to `100Gi`
* Update postgresql tag version to `13.2.0-debian-10-r55`
* Update postgresql chart version to `10.3.18` in chart.yaml - [10.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#to-1000)
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* **IMPORTANT**
* This chart is only helm v3 compatible
* Update rabbitmq tag version to `3.8.14-debian-10-r32`
* Update redis version tag to `6.2.1-debian-10-r9`
* Update alpine tag version to `3.13.5`
* Enable signedPipelines flag
* Fix broken support for startupProbe for k8s < 1.18.x
* Add support for autoSyncResourceIfOutdated flag

## [2.13.2] - May 10, 2021
* Pipelines v1.14.7
* Allow configuration of docker registry secret to pull kubernetes build node images (dind and reqKick)

## [2.13.1] - Apr 28, 2021
* Fix the reqSealer microservice wrong ending.

## [2.13.0] - Apr 19, 2021
* Always bring up reqSealer microservice

## [2.12.4] - Apr 22, 2021
* Configure router to see pipelines as a required service
* add volume mount to router state
* Disable router probes by default

## [2.12.3] - Apr 6, 2021
* Fix custom secrets range

## [2.12.2] - Apr 6, 2021
* Pipelines v1.14.2
* Fix custom secrets name and labels

## [2.12.1] - April 6, 2021
* Update alpine tag version to `3.13.4`

## [2.12.0] - Apr 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository

## [2.11.2] - Mar 30, 2021
* Add `timeoutSeconds` to all exec probes - Please refer [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)

## [2.11.1] - Mar 24, 2021
* Pipelines v1.14.1
* Optimized startupProbe time

## [2.11.0] - Mar 19, 2021
* Pipelines v1.14.0
* Run router container as default user

## [2.10.1] - Mar 19, 2021
* Fix Network Policy and custom secrets labels

## [2.10.0] - Mar 18, 2021
* Add support to startupProbe

## [2.9.1] - Mar 16, 2021
* Removed refernces to ClusterRole

## [2.9.0] - Mar 10, 2021
* Adds reqSealer microservice

## [2.8.6] - Mar 9, 2021
* Adding parameter for enabling livelog in the chart

## [2.8.5] - Mar 9, 2021
* Removed bintray URL references in the chart

## [2.8.4] - Mar 8, 2021
* Update RBAC rules for Pipelines

## [2.8.3] - Feb 28, 2021
* Add custom secret and custom pvc

## [2.8.2] - Feb 22, 2021
* Add liveness and readiness probes to router

## [2.8.1] - Feb 22, 2021
* Adds ability to disable nexec microservice

## [2.8.0] - Feb 16, 2021
* Pipelines v1.12.2

## [2.7.1] - Feb 08, 2021
* Corrected helpers.tpl variable names

## [2.7.0] - Feb 03, 2021
* Pipelines v1.11.3
* Establishing TLS between Pipelines & Artifactory, and Adding certificates
* Support for custom certificates using secrets
* **Important:** Switched docker images download from `docker.bintray.io` to `releases-docker.jfrog.io`
* Update alpine tag version to `3.13.1`

## [2.6.4] - Feb 1, 2021
* Adds settings for retention policies

## [2.6.3] - Jan 25, 2021
* Add support for hostAliases

## [2.6.2] - Jan 19, 2021
* Protect against yaml invalidating special characters in passwords

## [2.6.1] - Jan 19, 2021
* Adds default settings for metrics event logging

## [2.6.0] - Jan 12, 2021
* update system yaml to include buildImages for all supported OSs
* update default buildImages

## [2.5.5] - Jan 8, 2021
* Add support for creating additional kubernetes resources

## [2.5.4] - Dec 23, 2020
* Updated resource requests for the router container

## [2.5.3] - Dec 23, 2020
* Updated resource(memory) requests for the containers

## [2.5.2] - Dec 23, 2020
* Remove the quotes around nodePollerIntervalMS to maintain consistency

## [2.5.1] - Dec 23, 2020
* Adds nodePollerIntervalMS in systemYaml for buildPlane poller

## [2.5.0] - Dec 21, 2020
* Pipelines v1.10.0

## [2.4.1] - Dec 11, 2020
* Added configurable `.Values.global.versions.pipelines` in values.yaml

## [2.4.0] - Dec 10, 2020
* Update postgresql tag version to `12.5.0-debian-10-r25`
* Update rabbitmq tag version to `3.8.9-debian-10-r58`
* Update redis tag version to `6.0.9-debian-10-r39`
* Updated chart maintainers email

## [2.3.10] - Dec 9, 2020
* Added NetworkPolicy configurations (defaults to allow all)

## [2.3.9] - Dec 8, 2020
* mount logs volume to the router container

## [2.3.8] - Dec 4, 2020
* Remove the templateSync container's dependency on custom sidecar definitions

## [2.3.7] - Dec 4, 2020
* **Important:** Renamed `.Values.systemYaml` to `.Values.systemYamlOverride`

## [2.3.6] - Dec 3, 2020
* Update Pipelines services RBAC rules
* Make Pipelines services RBAC kind Role as default, with an option to switch to ClusterRole, it disables by default access to Cluster wide access

## [2.3.5] - Dec 3, 2020
* Change semverCompare checks to support hosted Kubernetes
* Updated port namings on services and pods to allow for istio protocol discovery
* Update alpine version to 3.12.1

## [2.3.4] Dec 1, 2020
* Pipelines v1.9.8

## [2.3.3] Nov 18, 2020
* Pipelines v1.9.2
* Fixed external Vault support

## [2.3.2] Nov 17, 2020
* Add support for `pipelines.extraEnvironmentVariables` to pass more environment variables to Pipelines services
* Bugfix - Issue with custom image tags

## [2.3.1] November 16, 2020
* Update console output with the correct url for accessing pipelines
* Pipelines v1.9.1

## [2.3.0] November 11, 2020
* Adds template microservice

## [2.2.1] Nov 10, 2020
* Added support to provide join-key and master-key from secret

## [2.2.0] Nov 10, 2020
* Add steps for using system.yaml via external secret for advanced use cases
* **IMPORTANT**
* Changed .Values.existingSecret to .Values.systemYaml.existingSecret and .Values.systemYaml.dataKey
* Add configurable support for vault-init container resources

## [2.1.1] Nov 20, 2020
* Pipelines v1.8.12

## [2.1.0] Nov 3, 2020
* Update bitnami rabbitmq chart to 7.7.1
* Readme update for using external database
* Fixed incorrect values in values-ingress-external-secret.yaml

## [2.0.4] October 26, 2020
* Readme update for upgrading rabbitmq

## [2.0.3] October 23, 2020
* Fix RabbitMQ extra service

## [2.0.2] October 21, 2020
* Corrected RabbitMQ properies in `values-ingress.yaml`

## [2.0.1] October 20, 2020
* Added support for external vault

## [2.0.0] Oct 19, 2020
* **Breaking change:** Updated `imagePullSecrets` value from string to list
* Added support for global values
* Updated maintainers in chart.yaml
* Update Pipelines version to `1.8.7`
* Update postgresql tag version to `12.3.0-debian-10-r71`
* Update redis sub chart version to `10.9.0`
* Update postgresql sub chart version to `9.3.4` - [9.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#900)
* Update rabbitmq sub chart version to `7.4.3` - [7.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq#to-700)
* Please refer [here](https://github.com/jfrog/charts/blob/master/stable/pipelines/README.md#special-upgrade-notes) for upgrade notes
* **IMPORTANT**
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x's postgresql.image.tag and databaseUpgradeReady=true

## [1.5.6] Oct 12, 2020
* Added configurable healthcheck for postgresDb
* Fixes the router configuration indentation

## [1.5.5] Oct 9, 2020
* Added configurable healthcheck for router
* Updated mantainers list in chart.yaml

## [1.5.4] Oct 8, 2020
* Changed customInitBeginContainer to customInitContainerBegin to match other jfrog charts
* Added examples in values.yaml for .Values.pipelines.customInitContainerBegin

## [1.5.3] Oct 7, 2020
* Adding custom init begin container to pipelines statefulset and vault statefulset
* Moved custom init container in vault statefulset from first to last position

## [1.5.2] Oct 5, 2020
* increasing liveness and readiness probe settings for api and www
* source above configs from values.yaml

## [1.5.1] Oct 5, 2020
* adding a healthcheck configuration within pipelines chart for artifactory

## [1.5.0] Oct 1, 2020
* Pipelines v1.8.0
* Added support for resources in init containers

## [1.4.9] September 30, 2020
* Supports router configuration to set internal artifactory endpoint for saas

## [1.4.8] September 29, 2020
* Hardcodes routers refresh interval for pipelines

## [1.4.7] September 25, 2020
* Changed init container to use linux capabilities CAP_CHOWN instead of runAsUser: 0

## [1.4.6] September 23, 2020
* Escalated privileges to init container only for pipelines-installer to work with pipelines images as non-root based for Openshift.

## [1.4.5] September 18, 2020
* Removed external Vault support as Pipelines does not support external vault until version 1.9.0
* Added disablemlock flag to enable users to set to false for production grade system security requirements.

## [1.4.4] September 17, 2020
* Change jfrogUrl and jfrogUrlUI default values
* Rename ci/test-values.yaml to ci/default-values.yaml

## [1.4.3] September 2, 2020
* Add external Vault support

## [1.4.2] - August 27, 2020
* Adds support for making api rabbitmq health check interval configurable
* Cleanup system.yaml
* Add RBAC rules for Pipelines Statefulset

## [1.4.1] - August 19, 2020
* Add support for external rabbitmq and redis

## [1.4.0] - Aug 8, 2020
* Pipelines v1.7.2
* Adds support for k8s build plane config
* Adds support for ssl enabled postgresql
* Support an existing secret for buildPlanes
* Add checksum for all secrets and configmaps

## [1.3.11] - August 6, 2020
* Fix external PG port

## [1.3.10] - August 5, 2020
* have controlplane and buildplane pull versions from global version override as specified in 1.3.7

## [1.3.9] - July 31, 2020
* Added support for customVolumes, configMaps and customInitcontainers for Vault
* Added tpl for resolving jfrogUrl

## [1.3.8] - July 30, 2020
* Fix customSideCar container bug for configMaps

## [1.3.7] - July 29, 2020
* Allow overriding default version of pipelines tags with a single value in values.yml
* add `# version:`  to pipelines:

## [1.3.6] - Jul 23, 2020
* Added support for customSidecarContainers, customVolumes, customInitcontainers and configMaps
* Update alpine version to 3.12

## [1.3.5] - July 20th, 2020
* Remove 'NodeType' option from pipelines-services-headless

## [1.3.4] - July 6th, 2020
* Fixes callHomeUrl

## [1.3.3] - June 30th, 2020
* Pipelines v1.6.2

## [1.3.2] - June 30, 2020
* Enable extensionSync microservice

## [1.3.1] - June 29, 2020
* Pipelines v1.6.1

## [1.3.0] - June 25, 2020
* Pipelines v1.6.0
* Adds a new configuration accessControlAllowOrigins
* Use ChartCenter as helm repo

## [1.2.0] - June 2, 2020
* Pipelines v1.5.1
* Update Postgres image to 9.6.18-debian-10-r7
* Disable Vault HA
* Bump alpine to v3.11

## [1.1.5] - May 13, 2020
* Pipelines v1.4.7

## [1.1.4] - April 30, 2020
* In readme fix helm template examples

## [1.1.3] - April 23, 2020
* Fix filebeat resources

## [1.1.2] - April 23, 2020
* Pipelines v1.4.6
* Removes subnetId and nat fields from buildplane config which are not supported from 1.4.x

## [1.1.1] - April 16, 2020
* Hardcode docker.bintray.io for build images

## [1.1.0] - April 15, 2020
* Pipelines v1.4.2
* Remove experimental k8s build plane support

## [1.0.36] - April 9, 2020
* Bump Redis chart to 10.6.3
* Bump RabbitMQ chart to 6.25.0
* Bump PostgreSQL chart to 8.7.3
* Bump Vault version to 1.3.4
* Fix k8s node compute resources

## [1.0.35] - April 3, 2020
* Update readme
* Disable Pipelines StatefulSet replicas if HPA is enabled

## [1.0.34] - March 24, 2020
* Update docs urls
* Fix filebeat compute resources

## [1.0.33] - March 24, 2020
* Add HPA for Pipelines services statefulset
* Add Runtime Override

## [1.0.32] - March 19, 2020
* Pipelines v1.3.3

## [1.0.31] - Mar 17, 2020
* Changed all single quotes to double quotes in values files

## [1.0.30] - Mar 11, 2020
* Unified charts public release

## [1.0.29] - March 10, 2020
* Fix CI test

## [1.0.28] - March 10, 2020
* Add CI test

## [1.0.27] - March 5, 2020
* Pipelines v1.3.2
* Bump Postgres to v9.6.17-debian-10-r21
* Update readme with `joinKey` instructions

## [1.0.26] - March 1, 2020
* Pipelines v1.3.1

## [1.0.25] - Feb 27, 2020
* Initial public release

## [1.0.24] - Feb 26, 2020
* Bump Redis chart to 10.5.6
* Bump RabbitMQ chart to 6.17.5
* Bump PostgreSQL chart to 8.4.2

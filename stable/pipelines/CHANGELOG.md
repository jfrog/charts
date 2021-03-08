# JFrog Pipelines Chart Changelog
All changes to this chart to be documented in this file

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

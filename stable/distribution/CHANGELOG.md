# JFrog Distribution Chart Changelog
All changes to this project chart be documented in this file.

## [6.1.0] -  Jul 7, 2020
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

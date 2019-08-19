# JFrog Distribution Chart Changelog
All changes to this project chart be documented in this file.

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

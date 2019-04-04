# JFrog Mission-Control Chart Changelog
All changes to this chart will be documented in this file.

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
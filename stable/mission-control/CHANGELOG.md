# JFrog Mission-Control Chart Changelog
All changes to this chart will be documented in this file.

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

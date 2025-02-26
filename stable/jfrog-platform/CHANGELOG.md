# JFrog Platform Chart Changelog (GA releases only)
All changes to this chart will be documented in this file.

## [11.0.3] - Feb 26, 2025
* Fixed sizing files

## [11.0.2] - Feb 26, 2025
* Added instructions to enable JFrog Advanced Security(JAS) in values.yaml
* Update dependency artifactory chart version to 107.104.10
* Update dependency xray chart version to 103.111.15
* Update dependency catalog chart version to 101.13.0

## [11.0.1] - Feb 14, 2025
* Upgrade initContainerSetupDBImage to postgres 16.6-alpine
* Added recommended sizing configurations under sizing directory, please refer [here](README.md/#apply-sizing-configurations-to-the-chart)

## [11.0.0] - Jan 30, 2025
* **Important changes**
* Upgrade rabbitmq chart version to 14.6.6
* Upgrade rabbitmq image to 3.13.7-debian-12-r2
* Upgrade postgres image to 16.6.0-debian-12-r2
* Removed installation of Insight and Pipelines product. You can use 10.x version of Jfrog-Platform to continue to use these products
* **Breaking changes**
* Upgrade postgres chart version to 15.5.20
    * This has many changes related to key names and path in values yaml
    * The effected keys present in default yaml have been aligned to the new path in 15.5.20
    * if you have customised any keys, make sure to validate it with the 15.5.20 chart
    * The statefulset will get deleted before upgrade through a preupgrade hook, as the updates on specific keys in sts is not allowed by kubernetes
    * Support to change postgres admin username is removed in postgres chart, will be postgres
* Added new dependency chart for catalog with version `101.11.1` and defaults to `false`
* Update dependency artifactory chart version to 107.104.5
* Update dependency xray chart version to 103.111.9
* Update dependency distribution chart version to 102.28.1
* Update dependency worker chart version to 101.118.0
* Added rabbitmq tolerations on pre-upgrade-hook [GH-1939](https://github.com/jfrog/charts/pull/1939)

## [10.20.1] - Nov 25, 2024
* Fix jfrog url with duplicate artifactory string when release name has artifactory
* Updated kubectl image to version `1.31.2`
* Update dependency artifactory chart version to 107.98.9
* Update dependency xray chart version to 103.107.11

## [10.20.0] - Oct 29, 2024
* **IMPORTANT**
* Added new dependency chart `worker` which is disabled by default and set `worker.enabled: true` to enable it. More info [here](https://jfrog.com/help/r/jfrog-installation-setup-documentation/installing-jfrog-worker)
* Commented `global.versions.router` to enable latest router version to picked from corresponding products
* Update dependency artifactory chart version to 107.98.7
* Update dependency distribution chart version to 102.27.2
* Update dependency worker chart version to 101.95.1

## [10.19.7] - Oct 23, 2024
* Added podSecurityContext and containerSecurityContext for pre-upgrade-check migration hook container. [GH-1929](https://github.com/jfrog/charts/pull/1929)
* Update dependency artifactory chart version to 107.90.15
* Update dependency xray chart version to 103.104.18

## [10.19.6] - Oct 8, 2024
* Fixed typo to get fourth parameter for setupPostgres.sh [GH-1992](https://github.com/jfrog/charts/pull/1992)
* Added `preUpgradeHook.tolerations`
* Update dependency artifactory chart version to 107.90.14
* Update dependency xray chart version to 103.104.17

## [10.19.5] - Sep 11, 2024
* Update dependency artifactory chart version to 107.90.10
* Update dependency xray chart version to 103.104.8

## [10.19.4] - Aug 28, 2024
* Update dependency artifactory chart version to 107.90.9
* Update dependency xray chart version to 103.103.6

## [10.19.3] - Aug 16, 2024
* Update dependency artifactory chart version to 107.90.8
* Update dependency xray chart version to 103.102.3
* Update global.versions.router version to `7.124.1`

## [10.19.2] - Aug 9, 2024
* Update dependency artifactory chart version to 107.90.7
* Update global.versions.router version to `7.124.0`

## [10.19.1] - Aug 6, 2024
* Update dependency artifactory chart version to 107.90.6
* Update dependency xray chart version to 103.101.5

## [10.19.0] - Jul 25, 2024
* **Important change:**
* Mission Control is also disabled by default now, if you are using this product from previous release, enable them using your custom-values.yaml file.
* Update dependency artifactory chart version to 107.90.5
* Update dependency xray chart version to 103.100.3
* Update global.versions.router version to `7.122.1`

## [10.18.3] - Jul 15, 2024
* Update dependency artifactory chart version to 107.84.17
* Update dependency xray chart version to 103.98.5

## [10.18.2] - June 12, 2024
* Update dependency artifactory chart version to 107.84.14
* Update dependency xray chart version to 103.96.1
* Fixed an issue related to chart artifactory fullname

## [10.18.1] - May 26, 2024
* Update dependency artifactory chart version to 107.84.12
* Update dependency xray chart version to 103.95.7
* Fixed an issue related to chart fullname when unifiedSecretInstallation is set to false [GH-1882](https://github.com/jfrog/charts/issues/1882)

## [10.18.0] - May 12, 2024
* **Important change:**
* Distribution, Insight and Pipelines are disabled by default, if you are using these products from previous release, enable them using your custom-values.yaml file.
* Added `preUpgradeHook.enabled` flag defaults to true to check if previous Distribution, Insight and Pipelines releases exists 
* Update postgresql tag version to `15.6.0-debian-11-r16`
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default bundles PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x/13.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* Added suppport for `global.imageRegistry` for initContainers 
* Updated rabbitmq tag version to `3.12.10-debian-11-r1`
* Added default resources for postgres-setup-init, pre-upgrade-check and rabbitmq's migration pre-upgrade-container container 
* Enabled `unifiedSecretInstallation` to true by default,which enables single unified secret holding all of each product secrets
* Update dependency artifactory chart version to 107.84.10
* Update dependency xray chart version to 103.94.6

## [10.17.4] - May 2, 2024
* Update dependency artifactory chart version to 107.77.11
* Update dependency xray chart version to 103.94.5
* Update dependency distribution chart version to 102.24.0
* Update global.versions.router version to `7.108.0`

## [10.17.3] - Mar 14, 2024
* Add missing IF statement in `NOTES.txt`
* Update dependency artifactory chart version to 107.77.7
* Update dependency xray chart version to 103.91.3

## [10.17.3] - Mar 14, 2024
* Add missing IF statement in `NOTES.txt`
* Update dependency artifactory chart version to 107.77.7
* Update dependency xray chart version to 103.91.3

## [10.17.1] - Feb 29, 2024
* Updated README.md to create a namespace using `--create-namespace` as part of helm install
* Updated `artifactory.installerInfo` content

## [10.17.0] - Jan 24, 2023
* **IMPORTANT**
* Added min kubeVersion ">= 1.19.0-0" in chart.yaml
* Removed "Waiting for artifactory to start" conditional check in `postgres-setup-init` init container
* Update pipelines to use its internal redis chart
* Removed obsolete dependency redis chart from chart.yaml
* Update `global.database.initContainerImagePullPolicy` to `IfNotPresent`
* Updated the chart Notes.txt content
* Fix the pre-upgrade-hook for rabbitmq migration
* Update dependency artifactory chart version to 107.77.3
* Update dependency xray chart version to 103.87.9
* Update dependency distribution chart version to 102.22.1
* Update dependency insight chart version to 101.16.6
* Update dependency pipelines chart version to 101.53.4
* Update global.versions.router version to `7.95.0`

## [10.16.5] - Jan 05, 2024
* Update dependency artifactory chart version to 107.71.11
* Update dependency xray chart version to 103.86.10
* Update dependency insight chart version to 101.16.5
* Update global.versions.router version to `7.91.0`

## [10.16.4] - Dec 21, 2023
* Update dependency artifactory chart version to 107.71.9
* Update dependency xray chart version to 103.86.9
* Update dependency distribution chart version to 102.21.3

## [10.16.3] - Dec 6, 2023
* Update dependency artifactory chart version to 107.71.5
* Update dependency xray chart version to 103.86.4
* Update dependency insight chart version to 101.16.2
* Update global.versions.router version to `7.87.0`
* Fixed an issue to use custom postgres DB port other than default 5432

## [10.16.2] - Nov 10, 2023
* Update dependency artifactory chart version to 107.71.4
* Update dependency xray chart version to 103.85.5

## [10.16.0] - Oct 26, 2023
* Update dependency artifactory chart version to 107.71.3
* Update dependency xray chart version to 103.83.10
* Update global.versions.router version to `7.81.0`

## [10.15.3] - Oct 16, 2023
* Update dependency artifactory chart version to 107.68.14
* Update dependency xray chart version to 103.83.9
* Update dependency distribution chart version to 102.20.3
* Update dependency pipelines chart version to 101.44.5

## [10.15.2] - Sep 28, 2023
* Update dependency artifactory chart version to 107.68.11
* Update dependency xray chart version to 103.82.11
* Update dependency distribution chart version to 102.20.2
* Update dependency insight chart version to 101.15.4
* Update global.versions.router version to `7.79.0`

## [10.15.1] - Sep 15, 2023
* Reverted - Enabled `unifiedSecretInstallation` by default [GH-1819](https://github.com/jfrog/charts/issues/1819)

## [10.15.0] - Sep 12, 2023
**IMPORTANT**
* Enabled `unifiedSecretInstallation` to true by default,which enables single unified secret holding all of each product secrets
* Update dependency artifactory chart version to 107.68.7
* Update dependency xray chart version to 103.82.6
* Update dependency distribution chart version to 102.20.1
* Fixed - Support to configure privateRegistry for xray pre-upgrade-hook
* Fixed rabbitmq feature flag conditions for pre-upgrade hook command execution
* Updated redis version to `7.2.0-debian-11-r2`
* Update global.versions.router version to `7.78.0`

## [10.14.8] - Aug 29, 2023
* Update dependency artifactory chart version to 107.63.14
* Update dependency insight chart version to 101.15.3
* Fixed - Added containerSecurityContext for xray's rabbitmq migration hook container
* Update global.versions.router version to `7.76.0`

## [10.14.7] - Aug 18, 2023
* Update dependency artifactory chart version to 107.63.12
* Update dependency xray chart version to 103.80.9

## [10.14.6] - Aug 10, 2023
* Update dependency artifactory chart version to 107.63.11
* Update dependency xray chart version to 103.79.11
* Update dependency pipelines chart version to 101.43.2

## [10.14.5] - Aug 4, 2023
* Update dependency artifactory chart version to 107.63.10

## [10.14.4] - Aug 2, 2023
* Update dependency artifactory chart version to 107.63.9
* Update dependency xray chart version to 103.78.11
* Update dependency pipelines chart version to 101.42.0
* Update global.versions.router version to `7.74.0`

## [10.14.3] - Jul 24, 2023
* Update dependency artifactory chart version to 107.63.7

## [10.14.2] - Jul 20, 2023
* Fixed - Added a conditional check if rabbitmq is enabled [GH-1794](https://github.com/jfrog/charts/issues/1794)

## [10.14.1] - Jul 18, 2023
* Update dependency xray chart version to 103.78.10
* Update global.versions.router version to `7.73.0`
* Added support for TLS in rabbitmq via `global.rabbitmq.tls.enabled`

## [10.14.0] - Jul 12, 2023
* Update dependency artifactory chart version to 107.63.5
* Update dependency xray chart version to 103.78.9
* Update dependency distribution chart version to 102.19.1
* Update dependency pipelines chart version to 101.41.3
* Update global.versions.router version to `7.70.2`
* Added list pods permission for rabbitmq's feature flag conditions, pre-upgrade hook command execution

## [10.13.3] - Jul 1, 2023
* Update dependency artifactory chart version to 107.59.11
* Update dependency xray chart version to 103.76.7
* Update dependency pipelines chart version to 101.40.5

## [10.13.2] - Jun 21, 2023
* Update dependency insight chart version to 101.14.0
* Update dependency pipelines chart version to 101.40.1
* Update global.versions.router version to `7.70.1`

## [10.13.1] - Jun 6, 2023
* Update dependency xray chart version to 103.75.12

## [10.13.0] - Jun 2, 2023
* Update dependency artifactory chart version to 107.59.9
* Update dependency distribution chart version to 102.18.1

## [10.12.3] - May 22, 2023
* Update dependency artifactory chart version to 107.55.13
* Update dependency pipelines chart version to 101.38.1
* Update global.versions.router version to `7.67.0`
* Remove sample url set for global.jfrogUrlUI

## [10.12.2] - May 3, 2023
* Update dependency artifactory chart version to 107.55.10
* Update dependency xray chart version to 103.71.6
* Update dependency pipelines chart version to 101.37.3
* Update dependency insight chart version to 101.13.5
* Added pre-upgrade hook (`rabbitmq.migration.enabled` defaults to true) for rabbitmq upgrade from 3.8.x to 3.11.x
* Added extraEnvs variable `JF_SHARED_RABBITMQ_VHOST` for supporting non-default `xray` vhost in xray

## [10.12.1] - Mar 27, 2023
* Update dependency artifactory chart version to 107.55.9
* Update dependency distribution chart version to 102.17.0
* Update dependency xray chart version to 103.69.3
* Update dependency insight chart version to 101.13.4
* Update dependency pipelines chart version to 101.35.3
* Update global.versions.router version to `7.61.2`
* Updated ARM supported postgresql version to `13.10.0-debian-11-r14`
* Updated ARM supported redis version to `7.0.9-debian-11-r6`
* Updated rabbitmq's chart version  to `11.9.3` and ARM supported rabbitmq version to `3.11.10-debian-11-r5`
* Added `rabbitmq.featureFlags` to support upgrade from 3.8.x to 3.11.x . More info [here](https://blog.rabbitmq.com/posts/2022/07/required-feature-flags-in-rabbitmq-3.11/)

## [10.12.0] - Mar 1, 2023
* Update dependency artifactory chart version to 107.55.2
* Update dependency pipelines chart version to 101.35.0
* Update global.versions.router version to `7.61.1`

## [10.11.6] - Feb 27, 2023
* Update dependency xray chart version to 103.67.9
* Update dependency distribution chart version to 102.16.6
* Update dependency pipelines chart version to 101.34.1

## [10.11.5] - Feb 16, 2023
* Update dependency artifactory chart version to 107.49.8
* Update dependency insight chart version to 101.13.3
* Update dependency pipelines chart version to 101.34.0

## [10.11.4] - Feb 7, 2023
* Update dependency xray chart version to 103.66.6
* Update dependency pipelines chart version to 101.33.0

## [10.11.3] - Jan 30, 2023
* Update dependency artifactory chart version to 107.49.6
* Update dependency xray chart version to 103.65.3
* Update dependency pipelines chart version to 101.32.2
* Update dependency distribution chart version to 102.16.2
* Update dependency insight chart version to 101.13.2

## [10.11.1] - Jan 16, 2023
* Update dependency artifactory chart version to 107.49.3
* Update dependency xray chart version to 103.64.4
* Update dependency pipelines chart version to 101.31.2
* Update dependency distribution chart version to 102.16.1
* Changed initContainerImage to `releases-docker.jfrog.io/ubi8/ubi-minimal:8.7.1049`

## [10.11.0] - Jan 6, 2023
* Update dependency artifactory chart version to 107.49.3
* Update dependency xray chart version to 103.63.2
* Update dependency pipelines chart version to 101.30.4
* Updated postgresql version to `13.9.0-debian-11-r11`
* Updated redis version to `7.0.6-debian-11-r0`

## [10.10.2] - Dec 22, 2022
* Update dependency artifactory chart version to 107.47.14
* Update dependency insight chart version to 101.13.1

## [10.10.1] - Dec 13, 2022
* Update dependency artifactory chart version to 107.47.12

## [10.10.0] - Dec 7, 2022
* Update dependency artifactory chart version to 107.47.11
* Update dependency xray chart version to 103.62.4
* Update dependency insight chart version to 101.13.0
* Update dependency pipelines chart version to 101.28.3
* Update global.versions.router version to `7.56.0`

## [10.9.4] - Nov 11, 2022
* Update dependency artifactory chart version to 107.46.11
* Update dependency xray chart version to 103.59.7
* Update dependency pipelines chart version to 101.28.1
* Updated global.versions.router version to `7.51.0`

## [10.9.3] - Oct 31, 2022
* Update dependency artifactory chart version to 107.46.10

## [10.9.2] - Oct 27, 2022
* Update dependency artifactory chart version to 107.46.8

## [10.9.1] - Oct 14, 2022
* Update dependency artifactory chart version to 107.46.6
* Update dependency xray chart version to 103.59.4

## [10.9.0] - Oct 11, 2022
* Remove filler Pipelines urls in values.yaml as they block default Pipeline's externalApi url from being used
* Updated rabbitmq version to `3.9.21-debian-11-r0`
* Removed the no longer used pipelines enablement configuration in artifactory subchart
* Update dependency artifactory chart version to 107.46.3
* Update dependency insight chart version to 101.12.1
* Update dependency pipelines chart version to 101.27.5

## [10.8.6] - Oct 4, 2022
* Update dependency distribution chart version to 102.15.0
* Update dependency pdn-server chart version to 101.2.0
* Updated global.versions.router version to `7.49.0`

## [10.8.5] - Sep 21, 2022
* Update dependency artifactory chart version to 107.41.13
* Update dependency xray chart version to 103.57.6
* Update dependency insight chart version to 101.12.0
* Update dependency pdn-server chart version to 101.1.3

## [10.8.4] - Sep 5, 2022
* Update dependency artifactory chart version to 107.41.12
* Update dependency distribution chart version to 102.14.3
* Update dependency pipelines chart version to 101.26.0

## [10.8.3] - Aug 18, 2022
* Update dependency xray chart version to 103.55.2
* Update dependency pipelines chart version to 101.25.1

## [10.8.2] - Aug 10, 2022
* Update dependency xray chart version to 103.54.5
* Update dependency pipelines chart version to 101.25.0

## [10.8.1] - Aug 3, 2022
* Update dependency artifactory chart version to 107.41.7
* Update dependency distribution chart version to 102.14.1
* Update dependency insight chart version to 101.11.5
* Update dependency pdn-server chart version to 101.0.5

## [10.8.0] - July 12, 2022
* Update dependency artifactory chart version to 107.41.4
* Update dependency xray chart version to 103.52.4
* Update dependency distribution chart version to 102.13.4
* Update dependency insight chart version to 101.11.3
* Update dependency pipelines chart version to 101.24.4
* Updated global.versions.router version to `7.42.0`

## [10.7.0] - June 21, 2022
* **IMPORTANT**
* Added [Private Distribution Network Server](https://www.jfrog.com/confluence/display/JFROG/Installing+PDN+Server) support
* Added pdn-server new chart version `101.0.3` and defaults to `false`
* Update dependency artifactory chart version to 107.39.4
* Update dependency xray chart version to 103.51.0
* Update dependency distribution chart version to 102.13.3
* Update dependency pipelines chart version to 101.24.0
* Updated global.versions.router version to `7.40.0`

## [10.6.3] - May 23, 2022
* Update dependency pipelines chart version to 101.23.6

## [10.6.2] - May 20, 2022
* Update dependency artifactory chart version to 107.38.10
* Update dependency xray chart version to 103.49.0

## [10.6.1] - May 16, 2022
* Update dependency artifactory chart version to 107.38.8
* Update dependency distribution chart version to 102.12.3
* Allow running the init DB container as a non-root user [GH-1544](https://github.com/jfrog/charts/pull/1544)

## [10.6.0] - May 9, 2022
* Update rabbitmq chart and image to 8.31.6 and 3.9.15-debian-10-r5
* Update dependency artifactory chart version to 107.38.7
* Update dependency xray chart version to 103.48.2
* Update dependency insight chart version to 101.10.2

## [10.5.2] - Apr 26, 2022
* Update dependency artifactory chart version to 107.37.15
* Update dependency xray chart version to 103.47.3
* Update dependency distribution chart version to 102.12.2
* Updated global.versions.router version to `7.38.0`

## [10.5.1] - Apr 18, 2022
* Update dependency artifactory chart version to 107.37.14
* Update dependency pipelines chart version to 101.22.4

## [10.5.0] - Apr 14, 2022
* Update dependency artifactory chart version to 107.37.13
* Update dependency xray chart version to 103.46.0
* Update dependency insight chart version to 101.9.0

## [10.4.1] - Mar 22, 2022
* Update dependency artifactory chart version to 107.35.2
* Update dependency xray chart version to 103.45.1
* Update dependency pipelines chart version to 101.22.0
* Updated global.versions.router version to `7.36.1`

## [10.4.0] - Mar 9, 2022
* Update dependency artifactory chart version to 107.35.1
* Update dependency xray chart version to 103.44.1
* Update dependency insight chart version to 101.7.0
* Update dependency distribution chart version to 102.12.1
* Updated global.versions.router version to `7.35.0`
* Changed dependency charts repo to `charts.jfrog.io`

## [10.3.2] - Feb 28, 2022
* Update dependency xray chart version to 103.43.1
* Update dependency distribution chart version to 102.12.0
* Update dependency pipelines chart version to 101.21.5

## [10.3.1] - Feb 17, 2022
* Update dependency artifactory chart version to 107.33.12
* Update dependency xray chart version to 103.42.5
* Update dependency insight chart version to 101.6.2
* Update dependency pipelines chart version to 101.21.2

## [10.3.0] - Feb 8, 2022
* Update dependency artifactory chart version to 107.33.9
* Update dependency distribution chart version to 102.11.0
* Updated global.versions.router version to `7.32.1`

## [10.2.0] - Jan 31, 2022
* Update dependency artifactory chart version to 107.31.13
* Update dependency xray chart version to 103.41.5
* Update dependency insight chart version to 101.5.0
* Update dependency pipelines chart version to 101.21.1
* Adding uniqueness for bitnami rabbitmq extraSecrets

## [10.1.2] - Dec 23, 2021
* Update dependency insight chart version to 101.3.0

## [10.1.1] - Dec 17, 2021
* Update dependency artifactory chart version to 107.29.8
* Update dependency xray chart version to 103.38.2
* Added distribution.initContainerImage to `releases-docker.jfrog.io/jfrog/ubi-minimal:8.5-204`

## [10.1.0] - Dec 7, 2021
* Added `artifactory.pipelines.enabled` flag to allow nginx instances in front of artifactory to allow websocket traffic
* Update dependency artifactory chart version to 107.29.7
* Update dependency distribution chart version to 102.10.5

## [10.0.4] - Nov 30, 2021
* Update dependency xray chart version to 103.37.2
* Updated global.versions.router version to `7.28.2`

## [10.0.3] - Nov 15, 2021
* Update dependency artifactory chart version to 107.27.10
* Update dependency xray chart version to 103.36.2
* Update dependency distribution chart version to 102.10.3
* Update dependency insight chart version to 101.1.3
* Update dependency pipelines chart version to 101.19.4

## [10.0.2] - Oct 29, 2021
* Update dependency artifactory chart version to 107.27.9
* Update dependency xray chart version to 103.35.0
* Update dependency insight chart version to 101.1.1
* Update dependency pipelines chart version to 101.19.3
* Removed Obsolete code

## [10.0.1] - Oct 22, 2021
* Update dependency xray chart version to 103.34.1
* Update dependency pipelines chart version to 101.18.8
* Updated `NOTES.txt` when `postgres.enabled:false`

## [10.0.0] - Oct 12, 2021
* **IMPORTANT**
* First GA release of the platform chart
* Version bump to align with all jfrog platform installers
* Added insight (new product) chart
* Missioncontrol is now part of artifactory chart (>= 107.27.x)
* **Breaking change**
* Removed `artifactory-ha` chart implies `artifactory` chart (>= 107.27.x) can be used for both single and HA modes
* If this is an upgrade over an existing platform chart (>= 10.0.0), explicitly pass 'gaUpgradeReady=true' to upgrade

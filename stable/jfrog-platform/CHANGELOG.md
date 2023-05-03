# JFrog Platform Chart Changelog (GA releases only)
All changes to this chart will be documented in this file.

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

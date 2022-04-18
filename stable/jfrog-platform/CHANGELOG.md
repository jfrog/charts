# JFrog Platform Chart Changelog (GA releases only)
All changes to this chart will be documented in this file.

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

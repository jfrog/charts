# JFrog Platform Chart Changelog
All changes to this chart will be documented in this file.

## [0.9.0] - Aug 13, 2021
* Update dependency artifactory/ha charts version to 107.24.3
* Update dependency xray chart version to 103.29.2
* Update dependency mission-control chart version to 104.7.11
* Update dependency distribution chart version to 102.9.0
* Update dependency pipelines chart version to 101.17.3

## [0.8.0] - Aug 13, 2021
* Update dependency artifactory/ha charts version to 107.23.3
* Update dependency xray chart version to 103.29.2
* Update dependency mission-control chart version to 104.7.11
* Update dependency distribution chart version to 102.9.0
* Update dependency pipelines chart version to 101.17.3

## [0.7.2] - July 28, 2021
* Update dependency artifactory/ha charts version to 107.21.12
* Update dependency xray chart version to 103.29.0

## [0.7.1] - July 14, 2021
* Update dependency artifactory/ha charts version to 107.21.7
* Update dependency distribution chart version to 102.8.2
* Update dependency xray chart version to 103.27.4

## [0.7.0] - July 9, 2021
* Added support for `global.versions.router` override tag
* Update dependency artifactory chart version to 107.21.5 (Artifactory 7.21.5)
* Update dependency artifactory-ha chart version to 107.21.5 (Artifactory 7.21.5)
* Update dependency pipelines chart version to 101.16.1 (Pipelines 1.16.1)
* Update dependency xray chart version to 103.27.3 (Xray 3.27.3)

## [0.6.0] - July 2, 2021
* Update dependency artifactory chart version to 107.21.3 (Artifactory 7.21.3)
* Update dependency artifactory-ha chart version to 107.21.3 (Artifactory 7.21.3)

## [0.5.0] - June 30, 2021
* **IMPORTANT**
* This chart is only helm v3 compatible
* Update dependency artifactory/ha charts version to 107.19.9
* Update dependency xray chart version to 103.26.1
* Update dependency distribution chart version to 102.8.1
* Update dependency pipelines chart version to 101.15.3
* Update dependency mission-control chart version to 104.7.7

## [0.4.1] - Apr 5, 2021
* Update dependency artifactory chart version to 11.13.0 (Artifactory 7.17.5)
* Update dependency artifactory-ha chart version to 4.13.0 (Artifactory 7.17.5)
* Update dependency xray chart version to 7.6.0 (Xray 3.21.2)
* Update dependency distribution chart version to 7.7.0 (Distribution 2.7.1)
* Update dependency pipelines chart version to 2.12.0 (Pipelines 1.14.1)
* Update dependency mission-control chart version to 5.8.0 (MissionControl 4.7.2)

## [0.4.0] - Apr 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository

## [0.3.0] - Mar 31, 2021
* Update dependency artifactory chart version to 11.12.2 (Artifactory 7.17.4)
* Update dependency artifactory-ha chart version to 4.12.2 (Artifactory 7.17.4)
* Update dependency xray chart version to 7.5.1 (Xray 3.21.2)
* Update dependency distribution chart version to 7.6.1 (Distribution 2.7.1)
* Update dependency pipelines chart version to 2.11.2 (Pipelines 1.14.1)
* Update dependency mission-control chart version to 5.7.1 (MissionControl 4.7.2)

## [0.2.0] - Mar 15, 2021
* Update dependency artifactory chart version to 11.10.0 (Artifactory 7.16.3)
* Update dependency artifactory-ha chart version to 4.10.0 (Artifactory 7.16.3)

## [0.1.2] - Mar 12, 2021
* Update dependency mission-control chart version to 5.5.3 (MissionControl 4.6.5)
* Update postgresql version tag to `13.2.0-debian-10-r30`
* Update rabbitmq version tag to `3.8.14-debian-10-r7`
* Update redis version tag to `6.2.1-debian-10-r9`

## [0.1.1] - Mar 9, 2021
* Update dependency artifactory chart version to 11.9.4 (Artifactory 7.15.4)
* Update dependency artifactory-ha chart version to 4.9.4 (Artifactory 7.15.4)
* Update dependency xray chart version to 7.1.1 (Xray 3.18.1)
* Update dependency distribution chart version to 7.4.3 (Distribution 2.6.1)
* Update dependency pipelines chart version to 2.8.5 (Pipelines 1.12.2)
* Update dependency mission-control chart version to 5.5.2 (MissionControl 4.6.3)

## [0.1.0] - Feb 19, 2021
* Update dependency artifactory chart version to 11.9.1 (Artifactory 7.15.3)
* Update dependency artifactory-ha chart version to 4.9.1 (Artifactory 7.15.3)
* Update dependency xray chart version to 7.0.2 (Xray 3.17.4)
* Update dependency distribution chart version to 7.4.1 (Distribution 2.6.0)
* Update dependency pipelines chart version to 2.8.0 (Pipelines 1.12.2)
* Update dependency mission-control chart version to 5.5.1 (MissionControl 4.6.3)
* Update postgresql version tag to `13.2.0-debian-10-r7`
* Update rabbitmq version tag to `3.8.12-debian-10-r2`
* Update redis version tag to `6.0.10-debian-10-r32`
* Added support to resolve jfrog url based on `global.artifactoryHaEnabled` flag

## [0.0.17] - Feb 11, 2021
* Update dependency xray chart version to 7.0.0 (Xray 3.17.2)
* Added support for global.versions.<product>

## [0.0.16] - Feb 09, 2021
* Added support to resolve jfrog url automatically

## [0.0.15] - Feb 08, 2021
* Update dependency artifactory chart version to 11.8.0 (Artifactory 7.12.8)
* Update dependency artifactory-ha chart version to 4.8.0 (Artifactory 7.12.8)
* Update dependency xray chart version to 6.11.0 (Xray 3.17.2)
* Update dependency distribution chart version to 7.4.0 (Distribution 2.6.0)
* Update dependency pipelines chart version to 2.7.1 (Pipelines 1.11.3)
* Update dependency mission-control chart version to 5.5.0 (MissionControl 4.6.3)

## [0.0.14] - Jan 27, 2021
* Update dependency artifactory chart version to 11.7.6 (Artifactory 7.12.6)
* Update dependency artifactory-ha chart version to 4.7.6 (Artifactory 7.12.6)
* Update dependency xray chart version to 6.10.0 (Xray 3.16.0)
* Update dependency distribution chart version to 7.3.2 (Distribution 2.6.0)
* Update dependency pipelines chart version to 2.5.5 (Pipelines 1.10.0)

## [0.0.13] - Jan 4, 2021
* Update dependency artifactory chart version to 11.7.4 (Artifactory 7.12.5)
* Update dependency artifactory-ha chart version to 4.7.4 (Artifactory 7.12.5)
* Update dependency xray chart version to 6.9.0 (Xray 3.15.1)
* Update dependency distribution chart version to 7.2.2 (Distribution 2.5.4)
* Update dependency mission-control chart version to 5.4.2 (MissionControl 4.6.2)
* Update dependency pipelines chart version to 2.3.8 (Pipelines 1.9.8)

## [0.0.12] - Dec 8, 2020
* Update dependency artifactory chart version to 11.5.5 (Artifactory 7.11.5)
* Update dependency artifactory-ha chart version to 4.5.5 (Artifactory 7.11.5)
* Update dependency xray chart version to 6.6.0 (Xray 3.13.0)
* Update dependency distribution chart version to 7.1.7 (Distribution 2.5.3)
* Update dependency mission-control chart version to 5.3.4 (MissionControl 4.6.1)
* Update dependency pipelines chart version to 2.3.7 (Pipelines 1.9.8)

## [0.0.11] - Dec 3, 2020
* Update dependency distribution chart version to 7.1.5 (Distribution 2.5.2)

## [0.0.10] - Dec 3, 2020
* Update dependency mission-control chart version to 5.3.3 (MissionControl 4.6.1)
* Update dependency pipelines chart version to 2.3.6 (Pipelines 1.9.8)

## [0.0.9] - Dec 3, 2020
* Update dependency artifactory chart version to 11.5.4 (Artifactory 7.11.5)
* Update dependency artifactory-ha chart version to 4.5.4 (Artifactory 7.11.5)
* Update dependency xray chart version to 6.5.0 (Xray 3.12.0)
* Update dependency distribution chart version to 7.1.4 (Distribution 2.5.2)
* Update dependency mission-control chart version to 5.3.2 (MissionControl 4.6.1)
* Update dependency pipelines chart version to 2.3.5 (Pipelines 1.9.8)

## [0.0.8] - Nov 23, 2020
* Update dependency artifactory chart version to 11.5.2 (Artifactory 7.11.2)
* Update dependency artifactory-ha chart version to 4.5.2 (Artifactory 7.11.2)
* Update dependency xray chart version to 6.4.2 (Xray 3.11.2)
* Update dependency distribution chart version to 7.1.4 (Distribution 2.5.2)
* Update dependency pipelines chart version to 2.1.1 (Pipelines 1.8.12)

## [0.0.7] - Nov 10, 2020
* Update dependency artifactory chart version to 11.4.5 (Artifactory 7.10.6)
* Update dependency artifactory-ha chart version to 4.4.5 (Artifactory 7.10.6)
* Update dependency xray chart version to 6.4.0 (Xray 3.11.1)

## [0.0.6] - Nov 4, 2020
* Update dependency xray chart version to 6.3.0
* Update dependency pipelines chart version to 2.1.0

## [0.0.5] - Nov 2, 2020
* Update dependency artifactory chart version to 11.4.4 (Artifactory 7.10.5)
* Update dependency artifactory-ha chart version to 4.4.4 (Artifactory 7.10.5)

## [0.0.4] - Oct 23, 2020
* Added Migration steps to move existing artifactory/artifactory-ha installations to JFrog platform chart - Refer [here](https://github.com/jfrog/charts/blob/master/stable/jfrog-platform/UPGRADE_NOTES.md)
* Updated dependency charts

## [0.0.3] - Oct 21, 2020
* Added new logo

## [0.0.2] - Oct 21, 2020
* Fix Logo path in chart.yaml
* Update artifactory dependency charts

## [0.0.1] - Oct 21, 2020
* Initial (Beta) release of jfrog-platform chart

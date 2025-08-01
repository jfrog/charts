# JFrog Artifactory CE for C++ Chart Changelog
All changes to this chart will be documented in this file

## [107.111.12] - Feb 17, 2024
* Fixed an issue by disabling a pro-only service (Onemodel)
* Disabling a pro-only service (Evidence)
* Updated federation key to rtfs in cpp, jcr and oss chart

## [107.103.0] - Dec 5, 2024
* Removed obsolete values [GH-1932](https://github.com/jfrog/charts/pull/1932)

## [107.81.0] - Feb 20, 2024
* Updated `artifactory.installerInfo` content

## [107.80.0] - Feb 1, 2024
* Updated README.md to create a namespace using `--create-namespace` as part of helm install

## [107.74.0] - Nov 23, 2023
* **IMPORTANT**
* Added min kubeVersion ">= 1.19.0-0" in chart.yaml

## [107.66.0] - Jul 20, 2023
* Disabled federation services when splitServicesToContainers=true

## [107.45.0] - Aug 25, 2022
* Included event service as mandatory and remove the flag from values.yaml

## [107.41.0] - Jul 22, 2022
* Bumping chart version to align with app version
* Disabled jfconnect and event services when splitServicesToContainers=true

## [107.19.4] - May 27, 2021
* Bumping chart version to align with app version
* Update dependency Artifactory chart version to 107.19.4

## [4.0.0] - Apr 22, 2021
* **Breaking change:**
* Increased default postgresql persistence  size to `200Gi` 
* Update postgresql tag version to `13.2.0-debian-10-r55`
* Update postgresql chart version to `10.3.18` in chart.yaml - [10.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#to-1000)
* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you**!
* If this is an upgrade and you are using the default PostgreSQL (`postgresql.enabled=true`), you need to pass previous 9.x/10.x/12.x's postgresql.image.tag, previous postgresql.persistence.size and databaseUpgradeReady=true
* **IMPORTANT**
* This chart is only helm v3 compatible.
* Update dependency Artifactory chart version to 12.0.0 (Artifactory 7.18.3)

## [3.8.0] - Apr 5, 2021
* **IMPORTANT**
* Added `charts.jfrog.io` as default JFrog Helm repository
* Update dependency Artifactory chart version to 11.13.0 (Artifactory 7.17.5)

## [3.7.0] - Mar 31, 2021
* Update dependency Artifactory chart version to 11.12.2 (Artifactory 7.17.4)

## [3.6.0] - Mar 15, 2021
* Update dependency Artifactory chart version to 11.10.0 (Artifactory 7.16.3)

## [3.5.1] - Mar 03, 2021
* Update dependency Artifactory chart version to 11.9.3 (Artifactory 7.15.4)

## [3.5.0] - Feb 18, 2021
* Update dependency Artifactory chart version to 11.9.0 (Artifactory 7.15.3)

## [3.4.1] - Feb 08, 2021
* Update dependency Artifactory chart version to 11.8.0 (Artifactory 7.12.8)

## [3.4.0] - Jan 4, 2020
* Update dependency Artifactory chart version to 11.7.4 (Artifactory 7.12.5)

## [3.3.1] - Dec 1, 2020
* Update dependency Artifactory chart version to 11.5.4 (Artifactory 7.11.5)

## [3.3.0] - Nov 23, 2020
* Update dependency Artifactory chart version to 11.5.2 (Artifactory 7.11.2)

## [3.2.2] - Nov 9, 2020
* Update dependency Artifactory chart version to 11.4.5 (Artifactory 7.10.6)

## [3.2.1] - Nov 2, 2020
* Update dependency Artifactory chart version to 11.4.4 (Artifactory 7.10.5)

## [3.2.0] - Oct 19, 2020
* Update dependency Artifactory chart version to 11.4.0 (Artifactory 7.10.2)

## [3.1.0] - Sep 30, 2020
* Update dependency Artifactory chart version to 11.1.0 (Artifactory 7.9.0)

## [3.0.2] - Sep 22, 2020
* Updates to readme

## [3.0.1] - Sep 15, 2020
* Update dependency Artifactory chart version to 11.0.1 (Artifactory 7.7.8)

## [3.0.0] - Sep 14, 2020
* **Breaking change:** Added `image.registry` and changed `image.version` to `image.tag` for docker images
* Update dependency Artifactory chart version to 11.0.0 (Artifactory 7.7.3)

## [2.5.1] - Jul 29, 2020
* Update dependency Artifactory chart version to 10.0.12 (Artifactory 7.6.3)

## [2.5.0] - Jul 10, 2020
* Update dependency Artifactory chart version to 10.0.3 (Artifactory 7.6.2)
* **IMPORTANT**
* Added ChartCenter Helm repository in README

## [2.4.0] - Jun 30, 2020
* Update dependency Artifactory chart version to 9.6.0 (Artifactory 7.6.1)

## [2.3.1] - Jun 1, 2020
* Update dependency Artifactory chart version to 9.5.2 (Artifactory 7.5.7)

## [2.3.0] - Jun 1, 2020
* Update dependency Artifactory chart version to 9.5.0 (Artifactory 7.5.5)

## [2.2.5] - May 27, 2020
* Update dependency Artifactory chart version to 9.4.9 (Artifactory 7.4.3)

## [2.2.4] - May 20, 2020
* Update dependency Artifactory chart version to 9.4.6 (Artifactory 7.4.3)

## [2.2.3] - May 07, 2020
* Update dependency Artifactory chart version to 9.4.5 (Artifactory 7.4.3)
* Add `installerInfo` string format

## [2.2.2] - Apr 28, 2020
* Update dependency Artifactory chart version to 9.4.4 (Artifactory 7.4.3)

## [2.2.1] - Apr 27, 2020
* Update dependency Artifactory chart version to 9.4.3 (Artifactory 7.4.1)

## [2.2.0] - Apr 14, 2020
* Update dependency Artifactory chart version to 9.4.0 (Artifactory 7.4.1)

## [2.1.6] - Apr 13, 2020
* Update dependency Artifactory chart version to 9.3.1 (Artifactory 7.3.2)

## [2.1.5] - Apr 8, 2020
* Update dependency Artifactory chart version to 9.2.8 (Artifactory 7.3.2)

## [2.1.4] - Mar 30, 2020
* Update dependency Artifactory chart version to 9.2.3 (Artifactory 7.3.2)

## [2.1.3] - Mar 30, 2020
* Update dependency Artifactory chart version to 9.2.1 (Artifactory 7.3.2)

## [2.1.2] - Mar 26, 2020
* Update dependency Artifactory chart version to 9.1.5 (Artifactory 7.3.2)

## [2.1.1] - Mar 25, 2020
* Update dependency Artifactory chart version to 9.1.4 (Artifactory 7.3.2)

## [2.1.0] - Mar 23, 2020
* Update dependency Artifactory chart version to 9.1.3 (Artifactory 7.3.2)

## [2.0.13] - Mar 19, 2020
* Update dependency Artifactory chart version to 9.0.28 (Artifactory 7.2.1)

## [2.0.12] - Mar 17, 2020
* Update dependency Artifactory chart version to 9.0.26 (Artifactory 7.2.1)

## [2.0.11] - Mar 11, 2020
* Unified charts public release

## [2.0.10] - Mar 8, 2020
* Update dependency Artifactory chart version to 9.0.20 (Artifactory 7.2.1)

## [2.0.9] - Feb 26, 2020
* Update dependency Artifactory chart version to 9.0.15 (Artifactory 7.2.1)

## [2.0.0] - Feb 12, 2020
* Update dependency Artifactory chart version to 9.0.0 (Artifactory 7.0.0)

## [1.1.1] - Feb 3, 2020
* Update dependency Artifactory chart version to 8.4.4

## [1.1.0] - Jan 19, 2020
* Update dependency Artifactory chart version to 8.4.1 (Artifactory 6.17.0)

## [1.0.1] - Dec 31, 2019
* Update dependency Artifactory chart version to 8.3.5

## [1.0.0] - Dec 23, 2019
* Update dependency Artifactory chart version to 8.3.3

## [0.2.1] - Dec 12, 2019
* Update dependency Artifactory chart version to 8.3.1

## [0.2.0] - Dec 1, 2019
* Updated Artifactory version to 6.16.0

## [0.1.3] - Nov 28, 2019
* Update dependency Artifactory chart version to 8.2.6

## [0.1.2] - Nov 22, 2019
* Update Artifactory logo

## [0.1.1] - Nov 20, 2019
* Initial release of the JFrog Artifactory CE for C++ helm chart

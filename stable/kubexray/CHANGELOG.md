# JFrog KubeXray Chart Changelog
All changes to this chart will be documented in this file.

## [0.3.8]  - Apr 2, 2019
* Updated Kubexray version to 0.1.3

## [0.3.7]  - Apr 2, 2019
* Rolling update to kubexray when secret-xray.yaml changes

## [0.3.6]  - Mar 20, 2019
* Updated Kubexray version to 0.1.2

## [0.3.5]  - Mar 18, 2019
* Added label selector for KubeXray ingress

## [0.3.4] - Mar 15, 2019
* Revert securityContext change that was causing issues

## [0.3.3] - Mar 13, 2019
* Move securityContext to container level

## [0.3.2] - Dec 12, 2018
* Fixed typo

## [0.3.1] - Dec 12, 2018
* Add `whitelistNamespaces` to all policies and fix some errors in [README.md]

## [0.2.10] - Dec 7, 2018
* Initial chart release

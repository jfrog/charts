# JFrog Mission-Control Chart Changelog
All changes to this chart will be documented in this file.

## [0.7.2] - Jan 22, 2019
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
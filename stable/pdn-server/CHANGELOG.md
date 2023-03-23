# JFrog PDN Server Chart Changelog
All changes to this chart will be documented in this file.

## [101.6.2] - Mar 06, 2023
* Updated initContainerImage `ubi9/ubi-minimal:9.1.0.1793`
* Removed unused global values
* Added `logLevel` option to systemYaml.pdnServer
* Added Bitnami nginx sub chart
* Unify system.yaml

## [101.5.5] - Jan 17, 2023
* Aligned variables name with JFrog Platform helm chart
* Updated initContainerImage to `ubi8/ubi-minimal:8.7.1049`
* Aligned network policy with Artifactory helm chart

## [101.5.1] - Jan 06, 2023
* Aligned values.yaml parameters between node and server charts
* Replaced readinessProbe with startupProbe

## [101.5.0] - Dec 26, 2022
* Renamed common chart to jfrog-common to avoid conflicts with Bitnami common chart
* Changed selfAddress value from localhost:8095 to pdn-server:8095

## [101.3.6] - Dec 7, 2022
* Upgraded Filebeat version up to 7.17.7
* Added additionaResorces and hostAliases

## [101.3.5] - Dec 1, 2022
* Upgraded common chart dependency up to 0.0.4
* Added containerSecurityContext to initContainers
* Updated fsGroup/runAsUser to 11055 to avoid host conflict
* Increased persistence storage size up to 16 Gb
* Updated initContainerImage to `ubi8/ubi-micro:8.7.1`

## [101.3.4] - Nov 22, 2022
* Updated chart to use jfrog common chart as dependency hence the prefix of `pdnServer.` is no more required when setting any flags
* Updated router version to 7.51.0 and observability to 1.12.0
* Removed unused parameters from values.yaml
* Added resources requests and limits to initContainers

## [101.1.3] - Aug 2, 2022
* Updated router version to 7.45.0
* Use an alternate command for `find` to copy custom certificates
* Updated initContainerImage and logger Image to `ubi8/ubi-minimal:8.6-854`
* Added `.Values.pdnServer.openMetrics.enabled` flag to enable metrics (defaults to `false`)
* Added flag `pdnServer.schedulerName` to set for the pods the value of schedulerName field [GH-1606](https://github.com/jfrog/charts/issues/1606)
* Updated Observability version to `1.9.3`

## [101.0.0] - May 04, 2022
* Initial support for Jfrog PDN Server

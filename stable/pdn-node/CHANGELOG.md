# JFrog PDN Node Chart Changelog
All changes to this chart will be documented in this file

## [101.7.6] - May 25, 2023
* Updated base image `ubi9/ubi-micro:9.2.5`
* Updated initContainerImage `ubi9/ubi-minimal:9.2.484`
* Changed podAntiAffinityPreset default value to hard
* Added ServiceMinotor object

## [101.7.3] - May 09, 2023
* Added checksum annotation to pod to auto-restart upon change to system.yaml

## [101.7.2] - May 07, 2023
* Upgraded common chart dependency up to 0.0.6
* Updated initContainerImage `ubi9/ubi-minimal:9.1.0.1829`
* Fixed network policy template issue
* Added ingress object

## [101.6.4] - Mar 06, 2023
* Updated initContainerImage `ubi9/ubi-minimal:9.1.0.1793`
* Removed unused global values
* Added `logLevel` option to systemYaml.pdnServer
* Added Bitnami nginx sub chart
* Unify system.yaml

## [101.5.5] - Jan 20, 2023
* Fixed empty updateStrategyType
* Aligned network policy with Artifactory helm chart

## [101.5.2] - Jan 17, 2023
* Aligned variables name with JFrog Platform helm chart
* Updated initContainerImage to `ubi8/ubi-minimal:8.7.1049`

## [101.5.1] - Jan 06, 2023
* Aligned values.yaml parameters between node and server charts
* Replaced readinessProbe with startupProbe
* Moved parameters from pdnNode scope to a main scope

## [101.5.0] - Dec 20, 2022
* Renamed common chart to jfrog-common to avoid conflicts with Bitnami common chart

## [101.3.6] - Dec 5, 2022
* Added additionaResorces and hostAliases

## [101.3.5] - Dec 1, 2022
* Upgraded common chart dependency up to 0.0.4
* Increased persistence storage size up to 64 Gb
* Added containerSecurityContext to initContainers
* Updated fsGroup/runAsUser to 11045 to avoid host conflict
* Updated initContainerImage to `ubi8/ubi-micro:8.7.1`

## [101.3.4] - Nov 22, 2022
* Removed unused parameters from values.yaml

## [101.3.0] - Nov 16, 2022
* Added Bitnami nginx sub chart
* Changed from deployment to statefulset
* Aligned persistence storage size with maximumMbToKeep
* Increased persistence storage size up to 20 Gb

## [101.2.0] - Sep 01, 2022
* Initial release

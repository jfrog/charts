# JFrog Worker Chart Changelog
All changes to this chart will be documented in this file

## [101.118.0] - Nov 12, 2024
* Add startup probe for worker container

## [101.105.0] - Nov 5, 2024
* Add pod disruption budget

## [101.102.0] - Oct 22, 2024
* Add service monitor for observability

## [101.95.0] - Sep 27, 2024
* Upgraded Observability version to 1.31.4

## [101.89.0] - Sep 02, 2024
* Added ability to provide `extraSystemYaml` configuration in values.yaml which will merge with the existing system yaml when `systemYamlOverride` is not given

## [101.86.0] - Aug 28, 2024
* Adjusted deployment for self-hosted release

## [101.42.0] - Dec 15, 2023
* Changed service monitor selector

## [101.29.0] - Sep 05, 2023
* Changed service monitor name and namespace

## [101.13.0] - May 03, 2023
* Adjusted KEDA autoscaling parameters

## [101.12.0] - April 27, 2023
* Removed busybox dependency
* Updated jfrog-common dep to `0.0.6`

## [101.5.0] - March 6, 2023
* Adjusted KEDA autoscaling parameters

## [101.4.0] - February 21, 2023
* Adjusted paths to new Worker service Docker base image
* Updated initContainers image to ubi9/ubi-minimal:9.1.0.1760

## [101.3.0] - February 15, 2023
* Aligned pod labels and annotations with other deployments

## [101.0.0] - January 17, 2023
* Renamed service and chart from Platform Extension to Worker

## [101.1.0] - January 06, 2023
* Refactored helm chart
* Added support for providing system.yaml configuration for containers in values.yaml

## [101.0.0] - January 03, 2023
* Initial release
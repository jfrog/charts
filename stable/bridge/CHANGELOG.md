# JFrog Bridge Chart Changelog

All changes to this chart will be documented in this file

## [101.262.52] - Aug 28, 2026
* Fixed a nil-pointer failure rendering the chart when `global.digests` is unset by the parent chart (e.g. `jfrog-platform` with `catalog`, `worker` or `wingman` also enabled)

## [101.213.0] - Jun 30, 2026
* Switch initContainer image to echo-mini:20260629

## [101.96.0] - May 26, 2026
* Added `serviceMonitor.additionalLabels` to merge extra labels into ServiceMonitor metadata (e.g. to satisfy `kube-prometheus-stack`'s `serviceMonitorSelector`)
* Added `serviceMonitor.relabelings` applied to every endpoint (bridge, router, observability) to allow Prometheus relabeling rules

## [101.77.0] - Apr 20, 2026
* Renamed router sidecar container port `http` to `http-router-in` to avoid duplicate port name warning during Helm install

## [101.70.0] - Mar 13, 2026
* Added support for `resources.disableCpuLimits` to optionally disable CPU limits (avoids CFS throttling for CPU-bound workloads)
* Resources for Bridge container, router, observability, loggers, and filebeat now use jfrog-common's `common.resources` helper
* Updated jfrog-common chart dependency to version 0.0.9

## [101.66.0] - Feb 18, 2026
* **Breaking changes**
* Change securityContext to containerSecurityContext in values.yaml
  * Key was renamed to unify with other charts
  * If you have customized securityContext in your values.yaml, make sure to rename the key to containerSecurityContext

## [101.64.0] - Feb 09, 2026
* Updated customVolumeMounts to extraVolumeMounts to allign all the services

## [101.59.0] - Jan 9, 2026
* Added support for `global.digests`
* Added `global.digests` for all `global.versions` related to image digests
* Example: `global.digests.bridge` to override Example: `bridge.image.digest`

## [101.40.0] - Sep 26, 2025
* Enable Observability by default

## [101.39.0] - Sep 19, 2025
* Added network policy

## [101.21.0] - June 6, 2025
* Updated paths to reflect changes in the docker image

## [101.11.0] - Apr 17, 2025
* Updated ubi-minimal version to 9.5.1742914212

## [101.8.0] - Apr 2, 2025

* Added support for multiple bridges in the client

## [101.5.0] - Mar 18, 2025

* Changed client configuration to use URL instead of scheme, host and port

## [101.0.0] - Feb 7, 2025

* Initial release
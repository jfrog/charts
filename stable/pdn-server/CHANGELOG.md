# JFrog PDN Server Chart Changelog
All changes to this chart will be documented in this file.

## [101.1.3] - Aug 2, 2022
* Updated router version to 7.45.0
* Use an alternate command for `find` to copy custom certificates
* Updated initContainerImage and logger Image to `ubi8/ubi-minimal:8.6-854`
* Added `.Values.pdnServer.openMetrics.enabled` flag to enable metrics (defaults to `false`)
* Added flag `pdnServer.schedulerName` to set for the pods the value of schedulerName field [GH-1606](https://github.com/jfrog/charts/issues/1606)
* Updated Observability version to `1.9.3`

## [101.0.0] - May 04, 2022
* Initial support for Jfrog PDN Server

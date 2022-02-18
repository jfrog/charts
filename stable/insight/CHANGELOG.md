# JFrog Insights Chart Changelog
All changes to this chart will be documented in this file.

## [101.6.2] - Jan 20, 2022
* Option to skip wait-for-db init container with '--set waitForDatabase=false'
* Added support for PriorityClass

## [101.5.0] - Jan 11, 2022
* Add more user friendly support for pod affinity and anti-affinity
* Pod anti-affinity is now enabled by default (soft rule)
* Added support for setting `fsGroupChangePolicy`
* Updated router version to `7.30.0`

## [101.4.0] - Dec 23, 2021
* Refactored `database-creds` secret to create only when database values are passed
* Refactored probes to replace httpGet probes with basic exec + curl
* Added new endpoints for probes `/api/v1/system/liveness` and `/api/v1/system/readiness`
* Enabled `newProbes:true` by default to use these endpoints
* Update elasticsearch version to `7.16.2`
* Fix filebeat sidecar spool file permissions
* Updated filebeat sidecar container to `7.16.2`

## [101.3.1] - Dec 20, 2021
* Change psql client check condition

## [101.3.0] - Dec 17, 2021
* Removed obsolete secret `applicationyaml`
* Update postgresql tag version to `13.4.0-debian-10-r39`
* Refactored `router.requiredServiceTypes` to support platform chart

## [101.2.3] - Nov 26, 2021
* Fixed incorrect permission for filebeat.yaml
* Updated logger image to `jfrog/ubi-minimal:8.5-204`

## [101.2.0] - Nov 26, 2021
* Enabled persistence for elasticsearch logs and change location to `insight/var/log`
* Update elasticsearch version to `7.15.1`
* Fixed chart values to use curl instead of wget [GH-1529](https://github.com/jfrog/charts/issues/1529)
* Moved router.topology.local.requireqservicetypes from system.yaml to router as environment variable
* Updated initContainerImage to `jfrog/ubi-minimal:8.5-204`
* Updated router version to `7.28.2`
* ** IMPORTANT **
* Added support for insightServer and insightScheduler `extraEnvironmentVariables` in values.yaml

## [101.1.0] - Oct 11, 2021
* Added default values cpu and memeory in initContainers
* Updated router version to `7.26.0`
* Updated (`rbac.create` and `serviceAccount.create` to false by default) for least privileges
* Fixed duplicate resource spec in insight-statefulset [GH-1507](https://github.com/jfrog/charts/issues/1507)
* Fixed incorrect data type for `Values.router.serviceRegistry.insecure` in default values.yaml [GH-1514](https://github.com/jfrog/charts/pull/1514/files)
* **IMPORTANT**
* Changed init-container images from `alpine` to `ubi8/ubi-minimal`

## [101.0.0] - Sep 20, 2021
* Bumping chart version to align with app version
* Added security hardening fixes
* Update elasticsearch version to `7.14.1`
* Updated router version to `7.25.1`
* Added min kubeVersion ">= 1.14.0-0" in chart.yaml
* Update alpine tag version to `3.14.2`
* Update busybox tag version to `1.33.1`
# JFrog Insights Chart Changelog
All changes to this chart will be documented in this file.

## [101.1.3] - Nov 13, 2021
* Change initcontainer image from ubi-minimal to ubi-micro insight base

## [101.1.3] - Nov 13, 2021
* Fixed insight persistence.mountPath in Custom certificate copy commands

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
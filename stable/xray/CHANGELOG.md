# JFrog Xray Chart Changelog
All changes to this chart will be documented in this file.

## [0.11.1] - Mar 26, 2019
* Add information about upgrading Xray with auto-generated postgres password

## [0.11.0] - Mar 26, 2019
* Switched to StatefulSets to preserve micro-service Ids

## [0.10.5] - Mar 18, 2019
* Added label selector for Xray ingress

## [0.10.4] - March 15, 2019
* Revert securityContext change that was causing issues

## [0.10.3] - March 13, 2019
* Move securityContext to container level

## [0.10.2] - March 12, 2019
* Updated Xray version to 2.7.3

## [0.10.1] - March 10, 2019
* Updated values.yaml added an important comment for the MongoDB requirements.

## [0.10.0] - Mar 3, 2019
* Support loggers sidecars to tail a configured log

## [0.9.0] - Feb 14, 2019
* Updated Xray version to 2.7.0

## [0.8.5] - Feb 11, 2019
* Add an option to set the indexAllBuilds configuration option in order to index all the builds in artifactory

## [0.8.4] - Feb 6, 2019
* Updated Postgres version to 9.6.11

## [0.8.3] - Feb 4, 2019
* Updated Xray version to 2.6.3

## [0.8.2] - Jan 24, 2019
* Added missing documentation about using `mongodb.enabled=false` when using external MongoDB

## [0.8.1] - Jan 22, 2019
* Added support for `common.customInitContainers` to create custom init containers

## [0.8.0] - Jan 1, 2019
* Updated Xray version to 2.6.0

## [0.7.8] - Dec 18, 2018
* Fix for 0.7.7 (Improve server health probes to support GKE ingress controller. Fixes https://github.com/jfrog/charts/issues/149)

## [0.7.7] - Dec 18, 2018
* Improve server health probes to support GKE ingress controller. Fixes https://github.com/jfrog/charts/issues/149

## [0.7.6] - Dec 11, 2018
* Using secret for external databases. Fixes https://github.com/jfrog/charts/issues/73

## [0.7.5] - Nov 14, 2018
* Fix bad example in [README.md]. Fixes https://github.com/jfrog/charts/issues/127.

## [0.7.4] - Nov 14, 2018
* Fix indent of `nodeSelector`, `affinity` and `tolerations` in the templates

## [0.7.3] - Nov 11, 2018
* Updated Xray version to 2.4.6

## [0.7.2] - Nov 4, 2018
* Replace POSTGRESS_ with POSTGRES_ (remove double S)

## [0.7.1] - Oct 30, 2018
* Updated Xray version to 2.4.2

## [0.7.0] - Oct 29, 2018
* Update postgresql chart to version 0.9.5 to be able and use `postgresConfig` options

## [0.6.3] - Oct 17, 2018
* Add Apache 2.0 license

## [0.6.2] - Oct 16, 2018
* Updated Xray version to 2.4.1

## [0.6.1] - Oct 11, 2018
* Allows ingress default `backend` to be enabled or disabled (defaults to enabled)
* Allows rabbitmq to be used instead of rabbitmq-ha by settings rabbitmq-ha.enabled: false and rabbitmq.enabled: true

## [0.6.0] - Oct 11, 2018
* Updated Xray version to 2.4.0

## [0.5.6] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [0.5.5] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [0.5.4] - Sep 30, 2018
* Add pods nodeSelector, affinity and tolerations

## [0.5.3] - Sep 26, 2018
* Updated Xray version to 2.3.3

## [0.5.1] - Sep 13, 2018
* Per service replica count

## [0.5.0] - Sep 3, 2018
* New RabbitMQ HA helm chart version 1.9.1
* Updated Xray version to 2.3.2

## [0.4.1] - Aug 22, 2018
* Updated Xray version to 2.3.0

## [0.4.0] - Aug 22, 2018
* Enabled RBAC support
* Added ingress support
* Updated Xray version to 2.2.4

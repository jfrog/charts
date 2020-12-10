# JFrog Xray Chart Changelog
All changes to this chart will be documented in this file.

## [2.5.1] - Dec 10, 2020
* Update Xray version to 2.16.11 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.11)
* Updated chart maintainers email

## [2.5.0] - Nov 9, 2020
* Change stable repository location to https://charts.helm.sh/stable
* Update Rabbitmq chart to v7.7.1

## [2.4.5] - Oct 30, 2020
* Update Xray version to 2.16.10 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.10)

## [2.4.4] - Oct 12, 2020
* Update Xray version to 2.16.6 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.6)

## [2.4.3] - Sep 23, 2020
* Update Xray version to 2.16.4 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.4)

## [2.4.2] - Sep 1, 2020
* Update Xray version to 2.16.2 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.2)
* Update rabbitmq-ha tag version to `3.8.7-alpine`
* Update rabbitmq tag version to `3.8.7-debian-10-r3`
* Updated chart maintainers.

## [2.4.1] - Aug 17, 2020
* Update Xray version to 2.16.1 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.1)
* Added support for Load Definitions for rabbitmq subchart when `rabbitmq.enabled=true` . Please refer [here](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq#load-definitions)

## [2.4.0] - Aug 3, 2020
* Update Xray version to 2.16.0 - [Release Notes](https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.16.0)
* Fixed `livenessProbe.path`, `readinessProbe.path` and updated README.

## [2.3.0] - Jul 20, 2020
* Update Xray version to 2.15.0 - https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.15.0

## [2.2.2] - Jul 13, 2020
* **IMPORTANT**
* Added ChartCenter Helm repository in README

## [2.2.1] - Jul 2, 2020
* Add support for Ingress version - `networking.k8s.io/v1beta1` for k8s >= 1.14 using helm v3
* Added compatability to support latest 7.x rabbitmq subchart when `rabbitmq.enabled=true`
* Update RabbitMQ chart to v7.4.3
* **IMPORTANT**
* RabbitMQ 7.x chart is [not compatible](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq#to-700) with previous rabbitmq 6.x chart in previous Xray 2.x charts
* Please refer [here](https://github.com/jfrog/charts/blob/pre-unified-platform/stable/xray/README.md#special-upgrade-notes) for upgrade notes

## [2.2.0] - Jun 29, 2020
* Update Xray version to 2.14.0 - https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.14.0
* Update RabbitMQ chart to v7.3.3
* Update RabbitMQ-HA chart to v1.46.4
* Update MongoDB chart to v7.14.8

## [2.1.2] - Jun 23, 2020
* Fix broken rabbitmq support when rabbitmq.enabled=true
* Update rabbitmq-ha tag version to `3.8.5-alpine`
* Update rabbitmq tag version to `3.8.5-debian-10-r14`
* Update alpine version to `3.12`
* Update busybox version to `1.31.1`

## [2.1.1] - Jun 18, 2020
* Ingress version fix

## [2.1.0] - Jun 15, 2020
* Update Xray version to 2.13.0 - https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.13.0

## [2.0.2] - May 29, 2020
* Readme and Upgrade note fixes.

## [2.0.1] - May 27, 2020
* Update Xray version to 2.12.1 - https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.12.1

## [2.0.0] - May 14, 2020
* Update Xray version to 2.12.0 - https://www.jfrog.com/confluence/display/XRAY2X/Release+Notes#ReleaseNotes-Xray2.12.0
* **Breaking change:** Added Upgrade Notes from 1.x to 2.x chart version - Refer https://github.com/jfrog/charts/blob/pre-unified-platform/stable/xray/UPGRADE_NOTES.md
* **Breaking change:** Added Support for Xray 2.x on k8s versions >= 1.16
* Added `databaseUpgradeReady` flag to upgrade from 1.x to 2.x chart versions
* Use dependency charts from https://charts.bitnami.com/bitnami
* Bump postgresql chart to 8.7.3
* Bump RabbitMQ chart to 6.25.2
* Bump RabbitMQ-HA chart to 1.44.2
* Bump MongoDB chart to 7.14.1

## [1.3.8] - Feb 18, 2020
* Update Xray version to 2.11.4

## [1.3.7] - Feb 13, 2020
* Fix Xray README `ingerss.additionalRules` description

## [1.3.6] - Feb 11, 2020
* Add support for `preStartCommand`

## [1.3.5] - Feb 2, 2020
* Add a comment stating that it is recommended to use external databases with a static password for production installations

## [1.3.4] - Jan 30, 2020
* Add the option to configure resources for the logger containers

## [1.3.3] - Dec 31, 2019
* Update Xray version to 2.11.3

## [1.3.2] - Dec 23, 2019
* Mark empty map values with `{}`

## [1.3.1] - Dec 1, 2019
* Added custom volume mounts to the server stateful set
* Added custom annotations to the server, indexer, analysis, and persist stateful sets

## [1.3.0] - Dec 3, 2019
* Update Xray version to 2.11.0

## [1.2.9] - Nov 24, 2019
* Fix the Xray probes path

## [1.2.8] - Nov 21, 2019
* Make the Xray probes customisable 

## [1.2.7] - Nov 21, 2019
* Prevent probes failing on 403 (Forbidden) - fixes

## [1.2.6] - Nov 20, 2019
* Prevent probes failing on 403 (Forbidden)

## [1.2.5] - Nov 20, 2019
* Update Xray logo

## [1.2.4] - Nov 7, 2019
* Update Xray version to 2.10.7

## [1.2.3] - Oct 28, 2019
* Update Xray version to 2.10.5

## [1.2.2] - Oct 26, 2019
* Update Xray version to 2.10.4

## [1.2.1] - Oct 7, 2019
* Update Xray version to 2.10.1

## [1.2.0] - Oct 3, 2019
* Update Xray version to 2.10.0

## [1.1.1] - Sep 26, 2019
* Add support for running custom init containers before the predefined init containers using `common.customInitContainersBegin` 

## [1.1.0] - Sep 3, 2019
* Update Xray version to 2.9.0

## [1.0.5] - Aug 13, 2019
* Add the option to provide a precreated secret for XRAY_MASTER_KEY

## [1.0.4] - Aug 11, 2019
* Add information about Xray ingress additionalRules

## [1.0.3] - Jul 22, 2019
* Change Ingress API to be compatible with recent kubernetes versions

## [1.0.2] - Jul 15, 2019
* Add the option to provide ingress additional rules

## [1.0.1] - Jul 15, 2019
* Updated README.md to the new defaults.

## [1.0.0] - Jul 9, 2019
* Set default server and indexer services persistence to `true`.
* **IMPORTANT:**
  * To upgrade from a previous Xray deployment, you have to pass the `--force` flag to the `helm upgrade` command.
  * This is mandatory to force the change services persistence to `true`.
  * This change will recreate the server and indexer pods!
  * **NOTE:** Don't forget to pass the DBs passwords to the `helm upgrade` if these were auto generated. See [README.md](README.md) for details in the **Upgrade** section.

## [0.12.17] - Jul 1, 2019
* Update Xray version to 2.8.9

## [0.12.16] - June 25, 2019
* Update Xray version to 2.8.8

## [0.12.15] - June 24, 2019
* Update chart maintainers

## [0.12.14] - June 23, 2019
* Add values files for small, medium and large installations

## [0.12.13] - June 20, 2019
* Document the mongoDB resources values suggestion
* Fix xray-server service annotation

## [0.12.12] - June 17, 2019
* Optional support for PostgreSQL with TLS

## [0.12.11] - June 7, 2019
* Update Xray version to 2.8.7
* Add persistence to Server and Indexer

## [0.12.10] - May 28, 2019
* Update Xray version to 2.8.6

## [0.12.9] - May 24, 2019
* Update stateful set api and add serviceName spec

## [0.12.8] - May 20, 2019
* Fix missing logger image tag

## [0.12.7] - Apr 16, 2019
* Updated Xray version to 2.8.3

## [0.12.6] - Apr 15, 2019
* Updated Xray version to 2.8.2

## [0.12.5] - May 12, 2019
* Updated rabbitmq-ha chart version to 1.26.0

## [0.12.4] - Apr 15, 2019
* Simplify handling connection strings setup in `xray_config.yaml` to better support ampersand in external connection strings
* **IMPORTANT:** If using an external connection string for PostgreSQL or MongoDB, **do not escape** the ampersand with `\`

## [0.12.3] - Apr 15, 2019
* Move `skipEntLicCheckForCloud: true` config to be part of default Xray config

## [0.12.2] - Apr 10, 2019
* Added support for customizing the xray_config.yaml file using a configmap 

## [0.12.1] - Apr 9, 2019
* Added Xray server service annotations 
  
## [0.12.0] - Apr 9, 2019
* Updated Xray version to 2.8.0

## [0.11.2] - Apr 7, 2019
* Add network policy support

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

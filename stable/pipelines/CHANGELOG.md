# JFrog Pipelines Chart Changelog
All changes to this chart to be documented in this file.

## [1.3.4] - July 6th, 2020
* Fixes callHomeUrl

## [1.3.3] - June 30th, 2020
* Pipelines v1.6.2

## [1.3.2] - June 30, 2020
* Enable extensionSync microservice

## [1.3.1] - June 29, 2020
* Pipelines v1.6.1

## [1.3.0] - June 25, 2020
* Pipelines v1.6.0
* Adds a new configuration accessControlAllowOrigins
* Use ChartCenter as helm repo

## [1.2.0] - June 2, 2020
* Pipelines v1.5.1
* Update Postgres image to 9.6.18-debian-10-r7
* Disable Vault HA
* Bump alpine to v3.11

## [1.1.5] - May 13, 2020
* Pipelines v1.4.7
 
## [1.1.4] - April 30, 2020
* In readme fix helm template examples

## [1.1.3] - April 23, 2020
* Fix filebeat resources

## [1.1.2] - April 23, 2020
* Pipelines v1.4.6
* Removes subnetId and nat fields from buildplane config which are not supported from 1.4.x

## [1.1.1] - April 16, 2020
* Hardcode docker.bintray.io for build images

## [1.1.0] - April 15, 2020
* Pipelines v1.4.2
* Remove experimental k8s build plane support

## [1.0.36] - April 9, 2020
* Bump Redis chart to 10.6.3
* Bump RabbitMQ chart to 6.25.0
* Bump PostgreSQL chart to 8.7.3
* Bump Vault version to 1.3.4
* Fix k8s node compute resources

## [1.0.35] - April 3, 2020
* Update readme
* Disable Pipelines StatefulSet replicas if HPA is enabled

## [1.0.34] - March 24, 2020
* Update docs urls
* Fix filebeat compute resources

## [1.0.33] - March 24, 2020
* Add HPA for Pipelines services statefulset
* Add Runtime Override

## [1.0.32] - March 19, 2020
* Pipelines v1.3.3

## [1.0.31] - Mar 17, 2020
* Changed all single quotes to double quotes in values files

## [1.0.30] - Mar 11, 2020
* Unified charts public release

## [1.0.29] - March 10, 2020
* Fix CI test

## [1.0.28] - March 10, 2020
* Add CI test

## [1.0.27] - March 5, 2020
* Pipelines v1.3.2
* Bump Postgres to v9.6.17-debian-10-r21
* Update readme with `joinKey` instructions

## [1.0.26] - March 1, 2020
* Pipelines v1.3.1

## [1.0.25] - Feb 27, 2020
* Initial public release 

## [1.0.24] - Feb 26, 2020
* Bump Redis chart to 10.5.6
* Bump RabbitMQ chart to 6.17.5
* Bump PostgreSQL chart to 8.4.2

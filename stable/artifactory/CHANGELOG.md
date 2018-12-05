# JFrog Artifactory Chart Changelog
All changes to this chart will be documented in this file.

## [7.7.10] - Dec 5, 2018
* Remove Distribution certificates creation.

## [7.7.9] - Nov 30, 2018
* Updated Artifactory version to 6.5.9

## [7.7.8] - Nov 29, 2018
* Updated postgresql version to 9.6.11

## [7.7.7] - Nov 27, 2018
* Updated Artifactory version to 6.5.8

## [7.7.6] - Nov 19, 2018
* Added support for configMap to use custom Reverse Proxy Configuration with Nginx

## [7.7.5] - Nov 14, 2018
* Fix location of `nodeSelector`, `affinity` and `tolerations`

## [7.7.4] - Nov 14, 2018
* Updated Artifactory version to 6.5.3

## [7.7.3] - Nov 12, 2018
* Support artifactory.preStartCommand for running command before entrypoint starts

## [7.7.2] - Nov 7, 2018
* Support database.url parameter (DB_URL)

## [7.7.1] - Oct 29, 2018
* Change probes port to 8040 (so they will not be blocked when all tomcat threads on 8081 are exhausted)

## [7.7.0] - Oct 28, 2018
* Update postgresql chart to version 0.9.5 to be able and use `postgresConfig` options

## [7.6.8] - Oct 23, 2018
* Fix providing external secret for database credentials

## [7.6.7] - Oct 23, 2018
* Allow user to configure externalTrafficPolicy for Loadbalancer

## [7.6.6] - Oct 22, 2018
* Updated ingress annotation support (with examples) to support docker registry v2

## [7.6.5] - Oct 21, 2018
* Updated Artifactory version to 6.5.2

## [7.6.4] - Oct 19, 2018
* Allow providing pre-existing secret containing master key
* Allow arbitrary annotations on primary and member node pods
* Enforce size limits when using local storage with `emptyDir`
* Allow providing pre-existing secrets containing external database credentials

## [7.6.3] - Oct 18, 2018
* Updated Artifactory version to 6.5.1

## [7.6.2] - Oct 17, 2018
* Add Apache 2.0 license

## [7.6.1] - Oct 11, 2018
* Supports master-key in the secrets and stateful-set
* Allows ingress default `backend` to be enabled or disabled (defaults to enabled)

## [7.6.0] - Oct 11, 2018
* Updated Artifactory version to 6.5.0

## [7.5.4] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [7.5.3] - Oct 4, 2018
* Add PostgreSQL resources template

## [7.5.2] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [7.5.1] - Oct 2, 2018
* Set Artifactory to 6.4.1

## [7.5.0] - Sep 27, 2018
* Set Artifactory to 6.4.0

## [7.4.3] - Sep 26, 2018
* Add ci/test-values.yaml

## [7.4.2] - Sep 2, 2018
* Updated Artifactory version to 6.3.2
* Removed unused PVC

## [7.4.0] - Aug 22, 2018
* Added support to run as non root
* Updated Artifactory version to 6.2.0

## [7.3.0] - Aug 22, 2018
* Enabled RBAC Support
* Added support for PostStartCommand (To download Database JDBC connector)
* Increased postgresql max_connections
* Added support for `nginx.conf` ConfigMap  
* Updated Artifactory version to 6.1.0

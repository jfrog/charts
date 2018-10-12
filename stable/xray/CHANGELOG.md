# JFrog Xray Chart Changelog
All changes to this chart will be documented in this file.

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
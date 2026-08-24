# Xray Quick Start

A minimal values file for getting Xray up and running quickly.

Update `global.jfrogUrl` and `global.joinKey` to match your Artifactory instance, and change the RabbitMQ and PostgreSQL passwords before using in any non-local environment.

See the [values-quick-start.yaml](values-quick-start.yaml) for the configuration example.

## Deploy

Always apply a sizing file to provide the correct resources to the containers. Download a sizing configuration (for example, `xray-xsmall`):

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-xsmall.yaml \
  -o xray-xsmall.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-quick-start.yaml -f xray-xsmall.yaml
```

# Xray on OpenShift

A values file for deploying Xray on OpenShift. Security contexts are disabled and service accounts / RBAC are enabled so the chart can run under OpenShift's restricted SCC defaults.

Update `global.jfrogUrl` and `global.joinKey` to match your Artifactory instance. The master key can be created separately for Xray. Change the RabbitMQ and PostgreSQL passwords before using in any non-local environment.

See the [values-openshift.yaml](values-openshift.yaml) for the configuration example.

## Deploy

Always apply a sizing file to provide the correct resources to the containers. Download a sizing configuration (for example, `xray-xsmall`):

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-xsmall.yaml \
  -o xray-xsmall.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-openshift.yaml -f xray-xsmall.yaml
```

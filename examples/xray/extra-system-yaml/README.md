# Xray Extra System YAML

This example shows how to add custom settings to Xray's `system.yaml` using the `extraSystemYaml` block.

Any values you need to add to the system YAML should be set via the `extraSystemYaml` block.

See the [values-extra-system-yaml.yaml](values-extra-system-yaml.yaml) for the configuration example.

## Deploy

Always apply a sizing file to provide the correct resources to the containers. Download a sizing configuration (for example, `xray-xsmall`):

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-xsmall.yaml \
  -o xray-xsmall.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-extra-system-yaml.yaml -f xray-xsmall.yaml
```

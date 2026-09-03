# Catalog Custom Trust Store

This example shows how to make Catalog trust a private/custom Certificate Authority using `customCertificates`.

See the [custom-trust-store-values.yaml](custom-trust-store-values.yaml) for the configuration example.

## How it works

`customCertificates.certificateSecretName` points to a Kubernetes secret containing one or more CA certificates:

```shell
kubectl create secret generic catalog-custom-ca --from-file=ca.crt=./my-ca.crt
```

When `customCertificates.enabled` is `true`, the chart copies every certificate from that secret into `$JFROG_HOME/catalog/var/etc/security/keys/trusted`, where Catalog's Java trust store picks them up. This is needed when Catalog talks to an internal service (Artifactory, an external database, etc.) whose TLS certificate isn't already trusted by the public CA bundle.

`global.customCertificates` sets the same behavior at the `jfrog-platform` umbrella level and applies it to every product subchart; the chart-root `customCertificates` shown here overrides it for Catalog alone.

## Deploy

```shell
helm upgrade --install catalog jfrog/catalog -f custom-trust-store-values.yaml
```
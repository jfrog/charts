# Trust Another JPD's Root Certificate for Access Federation

This example shows how to trust another JPD's root certificate for Access Federation on Artifactory HA, using `artifactory.circleOfTrustCertificatesSecret`, which names a pre-created Kubernetes Secret whose content the chart copies into `$JFROG_HOME/artifactory/var/etc/access/keys/trusted`.

See the [circle-of-trust-certificates-values.yaml](circle-of-trust-certificates-values.yaml) for the configuration example.

## How it works
- `artifactory.circleOfTrustCertificatesSecret` uses the same key, flat under the `artifactory:` block — same as the standalone chart, and **not** scoped under `artifactory.primary` unlike settings such as `resources`/`javaOpts` (see [ha-resource-sizing](../ha-resource-sizing)).
- Create the Secret containing the other JPD's root certificate first, then reference its name.
- This is a distinct mechanism from `global.customCertificates` (general outbound TLS trust) — circle-of-trust certs are specifically for Access Federation between JPDs.

## Deploy
```shell
kubectl create secret generic edge-root-crt --from-file=./edge-root.crt --namespace artifactory-ha
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f circle-of-trust-certificates-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [circle-of-trust-certificates](../../artifactory/circle-of-trust-certificates) — the standalone-chart version.
- [circle-of-trust-certificates](../../jfrog-platform/circle-of-trust-certificates) — the jfrog-platform umbrella-chart version.

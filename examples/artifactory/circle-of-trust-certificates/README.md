# Trust Another JPD's Root Certificate for Access Federation

Access Federation establishes a "circle of trust" between JPDs by exchanging root certificates. This example shows how to trust another JPD's root certificate using `artifactory.circleOfTrustCertificatesSecret`, which names a pre-created Kubernetes Secret whose content the chart copies into `$JFROG_HOME/artifactory/var/etc/access/keys/trusted`.

See the [circle-of-trust-certificates-values.yaml](circle-of-trust-certificates-values.yaml) for the configuration example.

## How it works
- Create the Secret containing the other JPD's root certificate first, then reference its name via `artifactory.circleOfTrustCertificatesSecret`.
- This is a distinct mechanism from `global.customCertificates` (which trusts a private CA for general outbound TLS verification, see [required-tls-nginx-secret](../required-tls-nginx-secret)) — circle-of-trust certs are specifically for Access Federation between JPDs, not general TLS trust.

## Deploy
```shell
kubectl create secret generic edge-root-crt --from-file=./edge-root.crt
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f circle-of-trust-certificates-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [circle-of-trust-certificates](../../artifactory-ha/circle-of-trust-certificates) — the artifactory-ha version.
- [circle-of-trust-certificates](../../jfrog-platform/circle-of-trust-certificates) — the jfrog-platform umbrella-chart version.
- [catalog/custom-trust-store](../../catalog/custom-trust-store) — a related but distinct mechanism (`customCertificates`) for trusting a private CA on the Catalog chart.

# Trust Another JPD's Root Certificate for Access Federation

This example shows how to trust another JPD's root certificate for Access Federation when Artifactory is deployed as a subchart of `jfrog-platform`, using `artifactory.artifactory.circleOfTrustCertificatesSecret`, which names a pre-created Kubernetes Secret whose content the chart copies into `$JFROG_HOME/artifactory/var/etc/access/keys/trusted`.

See the [circle-of-trust-certificates-values.yaml](circle-of-trust-certificates-values.yaml) for the configuration example.

## How it works
- The key is double-nested — `artifactory.artifactory.circleOfTrustCertificatesSecret` — because the standalone chart's own setting for this key lives inside its top-level `artifactory:` block (same tier as `license`, `persistence`; see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- Create the Secret containing the other JPD's root certificate first, then reference its name.
- This is a distinct mechanism from `global.customCertificates` (general outbound TLS trust) — circle-of-trust certs are specifically for Access Federation between JPDs.

## Deploy
```shell
kubectl create secret generic edge-root-crt -n jfrog-platform --from-file=./edge-root.crt
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f circle-of-trust-certificates-values.yaml
```

## Related
- [circle-of-trust-certificates](../../artifactory/circle-of-trust-certificates) — the standalone-chart version.
- [circle-of-trust-certificates](../../artifactory-ha/circle-of-trust-certificates) — the artifactory-ha version.
- [catalog/custom-trust-store](../../catalog/custom-trust-store) — a related but distinct mechanism (`customCertificates`) for trusting a private CA on the Catalog chart.

# Circle of Trust Certificates Across Products

Access Federation establishes a "circle of trust" between JPDs by exchanging root certificates. `circleOfTrustCertificatesSecret` names a pre-created Kubernetes Secret containing that root certificate; the chart copies it into `$JFROG_HOME/artifactory/var/etc/access/keys/trusted`. This is a distinct mechanism from `global.customCertificates` (which trusts a private CA for general outbound TLS verification, covered in [tls-across-products](../tls-across-products)) — circle-of-trust certs are specifically for Access Federation between JPDs.

<details>
  <summary>Artifactory</summary>

`artifactory.circleOfTrustCertificatesSecret` names the Secret. Create it first, then reference it.

See [circle-of-trust-artifactory-values.yaml](circle-of-trust-artifactory-values.yaml).

```shell
kubectl create secret generic edge-root-crt --from-file=./edge-root.crt
helm upgrade --install artifactory jfrog/artifactory -f circle-of-trust-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same key, same flat nesting under the `artifactory:` block as the standalone chart — not scoped under `artifactory.primary`, unlike settings such as `resources`/`javaOpts`.

See [circle-of-trust-artifactory-ha-values.yaml](circle-of-trust-artifactory-ha-values.yaml).

```shell
kubectl create secret generic edge-root-crt --from-file=./edge-root.crt --namespace artifactory-ha
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f circle-of-trust-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

Double-nested — `artifactory.artifactory.circleOfTrustCertificatesSecret` — because the standalone chart's own settings for this key live inside its top-level `artifactory:` block (same tier as `license`, `persistence`; see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).

See [circle-of-trust-jfrog-platform-values.yaml](circle-of-trust-jfrog-platform-values.yaml).

```shell
kubectl create secret generic edge-root-crt -n jfrog-platform --from-file=./edge-root.crt
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f circle-of-trust-jfrog-platform-values.yaml
```
</details>

## References
- [catalog/custom-trust-store](../../catalog/custom-trust-store) — a related but distinct mechanism (`customCertificates`) for trusting a private CA on the Catalog chart.
- [tls-across-products](../tls-across-products) — the general internal-CA/external-TLS model this topic complements.
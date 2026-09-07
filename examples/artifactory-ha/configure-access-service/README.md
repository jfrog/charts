# Configure the Access Service

JFrog Access handles authentication, tokens, and federation for the platform, and acts as the certificate authority when TLS between nodes is enabled. It runs as a container inside every Artifactory HA pod rather than as its own deployment. Most deployments need nothing here — change these values when Access is a bottleneck under load, when you supply your own certificate authority, or when the Access CA keys must be rotated.

See the [configure-access-service-values.yaml](configure-access-service-values.yaml) for the configuration example.

## How it works
- `access` is a top-level key, alongside `artifactory` rather than inside it, same as the standalone chart — not scoped under `artifactory.primary`.
- `access.customCertificatesSecretName` points every node in the cluster at the same certificate authority instead of the one each would otherwise generate. The Secret must be of type `kubernetes.io/tls`: `kubectl create secret tls access-ca --cert=ca.crt --key=ca.private.key --namespace artifactory-ha`.
- `access.resetAccessCAKeys: true` makes Access discard its certificate authority and generate a new one on the next start. **Resetting the CA invalidates every certificate it signed** — every product that trusted the old CA stops trusting the platform until it restarts and re-registers. Set this back to `false` once the reset has happened.
- `access.database.maxOpenConnections` and `access.tomcat.connector.*` tune Access's own connection pool and Tomcat connector, separate from Artifactory's.

## Deploy
```shell
kubectl create secret tls access-ca --cert=ca.crt --key=ca.private.key --namespace artifactory-ha
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f configure-access-service-values.yaml
```

## Related
- [configure-access-service](../../artifactory/configure-access-service) — the standalone-chart version.
- [configure-access-service](../../jfrog-platform/configure-access-service) — the jfrog-platform umbrella-chart version.
- [ha-tls-setup](../ha-tls-setup) — `access.accessConfig.security.tls`, the separate node-to-node TLS toggle this topic doesn't cover.

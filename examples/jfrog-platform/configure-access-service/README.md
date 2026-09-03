# Configure the Access Service

JFrog Access handles authentication, tokens, and federation for the platform, and acts as the certificate authority when TLS between nodes is enabled. It runs as a container inside the Artifactory pod rather than as its own deployment. Most deployments need nothing here — change these values when Access is a bottleneck under load, when you supply your own certificate authority, or when the Access CA keys must be rotated.

See the [configure-access-service-values.yaml](configure-access-service-values.yaml) for the configuration example.

## How it works
- The key is single-nested — `artifactory.access` — **not** double-nested like `artifactory.artifactory.*` settings. Access sits alongside the standalone chart's own `artifactory:` block, not inside it, so it only picks up the one subchart-name prefix (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for why some settings double-nest and others don't).
- `access.customCertificatesSecretName` points Access at your own certificate authority instead of the one it generates by default. The Secret must be of type `kubernetes.io/tls`: `kubectl create secret tls access-ca --cert=ca.crt --key=ca.private.key -n jfrog-platform`.
- `access.resetAccessCAKeys: true` makes Access discard its certificate authority and generate a new one on the next start. **Resetting the CA invalidates every certificate it signed** — in a multi-product deployment, expect connection failures across Xray and Distribution until each restarts and re-registers. Set this back to `false` once the reset has happened.
- `access.database.maxOpenConnections` and `access.tomcat.connector.*` tune Access's own connection pool and Tomcat connector, separate from Artifactory's.

## Deploy
```console
kubectl create secret tls access-ca --cert=ca.crt --key=ca.private.key -n jfrog-platform
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f configure-access-service-values.yaml
```

## Related
- [configure-access-service](../../artifactory/configure-access-service) — the standalone-chart version.
- [configure-access-service](../../artifactory-ha/configure-access-service) — the artifactory-ha version.
- [tls-end-to-end](../tls-end-to-end) — `access.accessConfig.security.tls`, the separate node-to-node TLS toggle this topic doesn't cover.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule, including the single- vs. double-nest distinction this topic is an example of.

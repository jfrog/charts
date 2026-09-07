# Configure the Access Service

JFrog Access handles authentication, tokens, and federation for the platform, and acts as the certificate authority when TLS between nodes is enabled. It runs as a container inside the Artifactory pod rather than as its own deployment. Most deployments need nothing here — change these values when Access is a bottleneck under load, when you supply your own certificate authority, or when the Access CA keys must be rotated.

See the [configure-access-service-values.yaml](configure-access-service-values.yaml) for the configuration example.

## How it works
- `access` is a top-level key, alongside `artifactory` rather than inside it — a value placed under `artifactory.access` instead is accepted by Helm and never applied.
- `access.customCertificatesSecretName` points Access at your own certificate authority instead of the one it generates by default. The Secret must be of type `kubernetes.io/tls`, holding the certificate and its private key: `kubectl create secret tls access-ca --cert=ca.crt --key=ca.private.key`.
- `access.resetAccessCAKeys: true` makes Access discard its certificate authority and generate a new one on the next start — use it when the CA private key is compromised or expired. **Resetting the CA invalidates every certificate it signed**: every product that trusted the old CA stops trusting the platform until it restarts and re-registers. Set this back to `false` once the reset has happened, or the keys regenerate on every restart.
- `access.database.maxOpenConnections` and `access.tomcat.connector.*` tune Access's own connection pool and Tomcat connector, separate from Artifactory's — raise them when Access itself is the bottleneck, not Artifactory. Raising `maxThreads` without raising `maxOpenConnections` just moves the bottleneck, and the database must permit the total connection count across all services.
- Enabling TLS between platform nodes is a separate mechanism — `access.accessConfig.security.tls` — covered in [required-tls-nginx-secret](../required-tls-nginx-secret).

## Deploy
```shell
kubectl create secret tls access-ca --cert=ca.crt --key=ca.private.key
helm upgrade --install artifactory jfrog/artifactory -f configure-access-service-values.yaml
```

Verify the Access container is running and check its log:
```shell
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n' | grep access
kubectl logs <pod-name> -c access | tail -20
```

## Related
- [configure-access-service](../../artifactory-ha/configure-access-service) — the artifactory-ha version (every node trusts the same CA).
- [configure-access-service](../../jfrog-platform/configure-access-service) — the jfrog-platform umbrella-chart version.
- [required-tls-nginx-secret](../required-tls-nginx-secret) — `access.accessConfig.security.tls`, the separate node-to-node TLS toggle this topic doesn't cover.

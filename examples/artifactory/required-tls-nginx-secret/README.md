# Required TLS Secret for the Nginx Ingress Controller

On a fresh install with `nginx.https.enabled` left at its default (`true`), the chart requires an explicit `nginx.tlsSecretName` (or `nginx.generateSelfSignedCert: true`) — if neither is set, the install fails with a clear error message instead of silently falling back to a self-signed cert. This example shows the recommended path: bring your own TLS Secret.

See the [required-tls-nginx-secret-values.yaml](required-tls-nginx-secret-values.yaml) for the configuration example.

## How it works
- Create the Secret first: `kubectl create secret tls artifactory-tls --cert=tls.crt --key=tls.key`.
- `nginx.tlsSecretName` points Nginx at that Secret for the HTTPS listener.
- `access.accessConfig.security.tls: true` makes JFrog Access act as the internal Certificate Authority, signing node-to-node TLS certificates so all Platform components communicate over TLS.
- On an existing install that is already running, this requirement doesn't retroactively apply — it only gates fresh installs so upgrades keep working. Install with `--set nginx.https.enabled=false` instead if you intentionally want HTTP only.

## Deploy
```shell
kubectl create secret tls artifactory-tls --cert=tls.crt --key=tls.key
helm upgrade --install artifactory jfrog/artifactory -f required-tls-nginx-secret-values.yaml
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also includes placeholder `nginx.tlsSecretName` — replace it with your own real TLS secret before deploying to a real cluster.
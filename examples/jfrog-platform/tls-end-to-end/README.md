# End-to-End TLS for the Platform Chart

This example enables TLS across Artifactory, Xray, and Distribution when they're deployed together through the `jfrog-platform` chart: Access acts as the internal Certificate Authority, Nginx terminates external TLS with your own certificate, and Xray/Distribution's routers are switched to verify the (self-signed) Access certificate instead of skipping verification.

See the [tls-end-to-end-values.yaml](tls-end-to-end-values.yaml) for the configuration example.

## How it works

- `artifactory.access.accessConfig.security.tls: true` turns on Access as the internal CA — all node-to-node traffic (Artifactory, Xray, Distribution talking to Access) is signed and encrypted. `accessConfig` is passed through verbatim into `access.config.yaml`, so any valid Access config key can be added there, including `tls-subject-alternative-names` if your nodes are reached by more than one DNS name.
- `artifactory.nginx.http.enabled: false` disables the plaintext listener so Nginx only serves HTTPS.
- `artifactory.nginx.tlsSecretName` points Nginx at a pre-existing Kubernetes TLS secret for the external-facing certificate. As of recent Artifactory chart versions, a fresh install requires this to be set explicitly (self-signed cert auto-generation is no longer the default).
- `xray.router.tlsEnabled` / `distribution.router.tlsEnabled` make each product's router communicate with Access over HTTPS instead of plaintext.
- `xray.router.serviceRegistry.insecure` / `distribution.router.serviceRegistry.insecure` control whether the router verifies Access's certificate. Set to `true` only when Access is using a self-signed certificate (the default when Access acts as its own CA); set to `false` once you've replaced it with a certificate from a trusted CA.

## Deploy

```console
kubectl create secret tls nginx-tls-secret --cert=nginx.crt --key=nginx.key -n jfrog-platform
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f tls-end-to-end-values.yaml
```

## Notes

- Under the platform chart, TLS-related values keep the same relative paths as their standalone-chart counterparts, just prefixed with the subchart name (`artifactory.`, `xray.`, `distribution.`) — see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting).
- Enabling `router.serviceRegistry.insecure: false` before Access has a trusted-CA certificate installed will break service registration — verify Access's certificate chain first.

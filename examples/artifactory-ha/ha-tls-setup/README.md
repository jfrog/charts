# HA TLS Setup

This example shows how to enable TLS for an Artifactory HA cluster using `access.accessConfig.security.tls` (internal node-to-node TLS) and `nginx.tlsSecretName` (external HTTPS on the nginx frontend).

From Artifactory 107.161.x, `nginx.tlsSecretName` (or `nginx.generateSelfSignedCert`) is required on a fresh install with `nginx.https.enabled: true` (the default) — installing without either fails with a clear error message.

See the [ha-tls-setup-values.yaml](ha-tls-setup-values.yaml) for the configuration example.

## How it works

- `access.accessConfig.security.tls: true` makes the Access service act as an internal Certificate Authority, signing TLS certificates so node-to-node communication across the HA cluster runs over TLS.
- `nginx.tlsSecretName` names a pre-existing Kubernetes TLS Secret (`kubectl create secret tls <name> --cert=tls.crt --key=tls.key`) that nginx uses for external HTTPS.
- On upgrade (not a fresh install), this field is not enforced: if a TLS Secret from a previous release already exists in the namespace, it's reused and HTTPS keeps working.
- For a quick non-production setup instead of a real certificate, set `nginx.generateSelfSignedCert: true` (ignored if `nginx.tlsSecretName` is also set).

## Deploy

1. Create the TLS Secret:
```bash
kubectl create secret tls nginx-tls-secret --cert=tls.crt --key=tls.key --namespace artifactory-ha
```
2. Install:
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f ha-tls-setup-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```
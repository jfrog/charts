# Bridge Tunnel Client Certificate

This example shows how to configure a JFrog Bridge client with a TLS Root CA certificate to trust when connecting to its **local** endpoint (for example a local Artifactory instance) over HTTPS, via `tunnelClientCertificateSecretName`.

This is needed when the local endpoint a bridge connects to uses a certificate that isn't already trusted by the system (for example, when Access uses its own CA rather than a publicly trusted one). It is not related to trust of the remote tunnel server.

Configuring the TLS Root CA per bridge in the Artifactory UI (see [Per-bridge CA in the UI](#per-bridge-ca-in-the-ui) below) is the preferred way to set this up. Use this chart value instead when you're not using the UI/API to configure bridges, or when multiple bridges on the same client need to trust the same certificate and you don't want to set it individually on each one.

See [client-cert-values.yaml](client-cert-values.yaml) for the configuration example.

## How it works

`tunnelClientCertificateSecretName` points to a Kubernetes secret containing the CA certificate to trust, keyed as `tls_cert.crt`:

```shell
kubectl create secret generic tunnel-client-certificate \
  --from-literal=tls_cert.crt="$(curl -s -H "Authorization: Bearer $TOKEN" http://<artifactory-url>/access/api/v1/cert/ca)"
```

By default, Bridge trusts the Root CA certificate it fetches from the local Access instance it's registered against. This file is only needed when the certificate presented by a bridge's local URL doesn't match that Access-provided CA (for example, the local endpoint is fronted by a different TLS certificate than Access itself).

When the value is set, Bridge:

1. Mounts the secret into an init container.
2. Copies `tls_cert.crt` to `/var/opt/jfrog/bridge/data/bridge/tls_cert.crt` before the main container starts.
3. The bridge client process reads the certificate from that path at startup and uses it as the default TLS Root CA for all its bridges instead of the Access-provided one — used for readiness checks against each bridge's local URL, and forwarded to the remote tunnel server so it can validate/proxy the connection to the local endpoint over TLS.

## Deploy

Create the secret, then install Bridge with the following command:

```shell
helm upgrade --install bridge jfrog/bridge -f client-cert-values.yaml
```

## Per-bridge CA in the UI

This chart-level certificate acts as the default for all bridges configured on the client. A different, bridge-specific TLS Root CA can also be provided per bridge directly in the Artifactory UI when configuring a bridge/tunnel connection — it takes precedence over the default certificate configured here for that bridge only. This is useful when different bridges on the same client need to trust different local CAs.

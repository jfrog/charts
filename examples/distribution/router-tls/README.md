# Router TLS

This example enables TLS on Distribution's `router` container using `router.tlsEnabled` and `router.serviceRegistry.insecure`.

See the [router-tls-values.yaml](router-tls-values.yaml) for the configuration example.

## How it works

- `router.tlsEnabled: true` makes the router terminate HTTPS instead of plain HTTP on its internal/external ports.
- `router.serviceRegistry.insecure` controls whether the router skips TLS verification when it registers itself with Access. Set it to `true` only when the Access endpoint uses a self-signed certificate (for example, the default JFrog Platform internal CA) — leave it `false` when Access has a certificate from a trusted CA.
- This mirrors the same `router.tlsEnabled`/`router.serviceRegistry.insecure` pair used by Xray, since both charts share the same router component.

## Deploy

```shell
helm upgrade --install distribution jfrog/distribution -f router-tls-values.yaml
```
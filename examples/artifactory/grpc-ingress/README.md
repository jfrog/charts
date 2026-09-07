# Configure gRPC and Custom Ingress

gRPC runs over HTTP/2 and needs different proxy settings than the HTTP/1.1 traffic Artifactory serves for everything else. Mixing them on one Ingress means the connection settings suit one protocol and hurt the other, so the chart creates a second Ingress dedicated to gRPC via `ingressGrpc`. Where neither the standard nor the gRPC Ingress fits, `customIngress` lets you supply a complete Ingress definition of your own.

See the [grpc-ingress-values.yaml](grpc-ingress-values.yaml) for the configuration example.

## How it works
- `ingressGrpc` is disabled by default. Enabling it creates both a backing Service and an Ingress routing the gRPC path (`grpcPath`, which defaults to `/com.jfrog` — the path prefix Artifactory's gRPC services use).
- The TLS secret referenced under `ingressGrpc.tls` must already exist in the release namespace.
- Without a backend-protocol annotation telling the controller the backend speaks gRPC, the Ingress is created but forwards traffic as HTTP/1.1 and clients fail with protocol errors rather than a routing error. On the community NGINX controller that's `nginx.ingress.kubernetes.io/backend-protocol: GRPCS`; other controllers use their own annotation name.
- Set `ingressGrpc.enableServiceOnly: true` instead when an external or multi-tenant ingress already routes gRPC — the chart then creates only the backing Service and skips the Ingress object.
- `customIngress` takes a complete Ingress definition as a `tpl`-rendered string, applied as-is with no validation from the chart — a malformed definition surfaces as a Kubernetes API rejection, not a Helm error. Disable `ingress.enabled` when using it, otherwise two Ingress objects compete for the same host.

## Deploy
```shell
kubectl create secret tls artifactory-grpc-tls --cert=grpc-tls.crt --key=grpc-tls.key
helm upgrade --install artifactory jfrog/artifactory -f grpc-ingress-values.yaml
```

## Verify
```bash
kubectl get ingress,service --namespace <namespace>
kubectl describe ingress <release-name>-artifactory-grpc --namespace <namespace>
```

## Related
- [grpc-ingress](../../artifactory-ha/grpc-ingress), [grpc-ingress](../../jfrog-platform/grpc-ingress) — the HA and platform-chart versions of this example.
- [gateway-api-ingress](../gateway-api-ingress) — a different mechanism (Kubernetes Gateway API) for exposing Artifactory.
- [nginx-ingress-controller-platform](../../jfrog-platform/nginx-ingress-controller-platform) — installing the NGINX Ingress Controller itself.

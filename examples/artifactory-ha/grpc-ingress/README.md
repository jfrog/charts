# Configure gRPC and Custom Ingress

gRPC runs over HTTP/2 and needs different proxy settings than the HTTP/1.1 traffic Artifactory serves for everything else. The chart creates a second Ingress dedicated to gRPC via `ingressGrpc`, so the two protocols don't share connection settings on one Ingress. Where neither the standard nor the gRPC Ingress fits, `customIngress` lets you supply a complete Ingress definition of your own.

See the [grpc-ingress-values.yaml](grpc-ingress-values.yaml) for the configuration example.

## How it works
- Same two top-level keys as the standalone chart — `ingressGrpc` and `customIngress` are not renested for HA.
- `ingressGrpc` is disabled by default. Enabling it creates both a backing Service and an Ingress routing the gRPC path (`grpcPath`, default `/com.jfrog`).
- Without a backend-protocol annotation, the Ingress is created but forwards traffic as HTTP/1.1 and clients fail with protocol errors. On the community NGINX controller that's `nginx.ingress.kubernetes.io/backend-protocol: GRPCS`.
- Set `ingressGrpc.enableServiceOnly: true` instead when an external or multi-tenant ingress already routes gRPC.
- `customIngress` takes a complete Ingress definition, rendered as-is with no validation from the chart. Disable `ingress.enabled` when using it, otherwise two Ingress objects compete for the same host.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f grpc-ingress-values.yaml
```

## Related
- [grpc-ingress](../../artifactory/grpc-ingress), [grpc-ingress](../../jfrog-platform/grpc-ingress) — the standalone and platform-chart versions of this example.

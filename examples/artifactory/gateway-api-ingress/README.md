# Kubernetes Gateway API Ingress

This example exposes Artifactory through the Kubernetes Gateway API instead of a classic `Ingress` object, via `gatewayApi.enabled`. Requires `artifactory`/`artifactory-ha` chart `107.161.15`+ (or `jfrog-platform` `11.6.0`+, which bundles it).

See the [gateway-api-ingress-values.yaml](gateway-api-ingress-values.yaml) for the configuration example.

## How it works
- `gatewayApi.enabled: true` makes the chart create a `Gateway` and an `HTTPRoute` — comparable to what `ingress.enabled` does for classic Ingress, but targeting `gateway.networking.k8s.io` resources instead.
- The Gateway API CRDs are **not** built into Kubernetes and must be installed separately, and you need a running Gateway controller (JFrog validates NGINX Gateway Fabric) — without one, the `Gateway` resource is created but never programmed, and no traffic reaches Artifactory.
- `gatewayApi.gatewayClassName` must exactly match an existing `GatewayClass` in your cluster (`kubectl get gatewayclass`), or the install fails fast with `gatewayApi.gatewayClassName is required when gatewayApi.enabled is true`.
- `nginx.enabled: false` is required — the chart doesn't automatically disable the bundled Nginx pod just because you enabled the Gateway API, and leaving both on provisions two external load balancers with only one actually receiving traffic.
- `routerPath`/`artifactoryPath` mirror the same two-path split (`/` → Router, `/artifactory/` → direct Artifactory) used by `ingress.*`.

## Deploy
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
kubectl get gatewayclass
```

> `helm template`/`helm install` against a cluster (or API server) without the Gateway API CRDs installed fails fast with `gatewayApi.enabled is true but Gateway API CRDs ... are not installed`. That's the chart working as designed, not a bug — install the CRDs first. To dry-run this example without a live cluster, add `--api-versions gateway.networking.k8s.io/v1` to `helm template`.
```shell
helm upgrade --install artifactory jfrog/artifactory --namespace artifactory --create-namespace -f gateway-api-ingress-values.yaml
```

## Related
### JFrog Platform
Nest the same keys one level under `artifactory:` — see [platform-vs-standalone-nesting](../../jfrog-platform/platform-vs-standalone-nesting):
```yaml
artifactory:
  nginx:
    enabled: false
  gatewayApi:
    enabled: true
    gatewayClassName: "nginx"
    hosts: [artifactory.example.com]
```
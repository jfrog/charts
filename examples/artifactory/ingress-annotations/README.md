# Custom Ingress Annotations and Additional Rules

This example configures the chart's own `Ingress` object — a custom hostname, TLS, Docker-Registry-via-Repository-Path annotations, and an additional path rule routing `/xray` to a separate service — via `ingress.*`.

See the [ingress-annotations-values.yaml](ingress-annotations-values.yaml) for the configuration example.

## How it works
- `ingress.hosts`/`ingress.tls`/`ingress.annotations` create a standard Kubernetes `Ingress` object; `nginx.enabled: false` disables the chart's bundled Nginx Service so the Ingress controller is the only entry point (leaving both on creates two competing paths into Artifactory).
- The `nginx.ingress.kubernetes.io/configuration-snippet` annotation rewrites Docker v2 API paths so Artifactory can serve as a Docker registry via repository paths (`myhost.example.com/artifactory/api/docker/<repo>`) instead of subdomains.
- **`ingress.additionalRules` must be a YAML block-scalar string, not a native list.** The template renders it with Helm's `tpl` function (`{{ tpl . $ | indent 2 }}` in `templates/ingress.yaml`) — passing a real YAML list here aborts the install with `wrong type for value; expected string; got []interface{}`. This is a real, currently-documented-incorrectly trap: older docs show this as a list.
- Which annotation prefix applies (`nginx.ingress.kubernetes.io/` vs `nginx.org/`) depends on which Ingress controller you run — see [nginx-ingress-controller-platform](../../jfrog-platform/nginx-ingress-controller-platform) for the other controller's prefix and the pitfall of mixing them up.

## Deploy
```shell
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory -f ingress-annotations-values.yaml
```

## Related
- [nginx-ingress-controller-platform](../../jfrog-platform/nginx-ingress-controller-platform) — the F5 NGINX Ingress Controller equivalent (different annotation prefix, different chart).
- [gateway-api-ingress](../gateway-api-ingress) — the Gateway API alternative to Ingress annotations.
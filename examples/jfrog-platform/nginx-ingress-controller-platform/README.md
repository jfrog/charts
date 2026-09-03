# JFrog Platform with an External NGINX Ingress Controller

This example exposes `jfrog-platform` through an NGINX Ingress Controller you install and manage yourself, instead of the Nginx pod bundled with the chart, via `artifactory.nginx.enabled: false` + `artifactory.ingress.enabled: true`.

See the [nginx-ingress-controller-platform-values.yaml](nginx-ingress-controller-platform-values.yaml) for the configuration example.

## How it works
- Two different products are both called "NGINX Ingress Controller" and read **different annotation prefixes** — the F5 NGINX Ingress Controller (`nginx/nginx-ingress` chart, `nginx.org/` annotations, used below) and the Kubernetes community controller (`ingress-nginx/ingress-nginx` chart, `nginx.ingress.kubernetes.io/` annotations). Each silently ignores the other's annotations with no error — the config *looks* correct in `kubectl describe ingress` while doing nothing, and the failure only surfaces later (uploads failing at a default size limit, `docker login` returning 404).
- The `nginx.org/location-snippets` annotation carries the Docker-registry-via-repository-path rewrite rules, but **snippet support is off by default** on the F5 controller — install/upgrade it with `--set controller.enableSnippets=true` or these annotations are discarded silently.
- All three key blocks (`artifactory.nginx.enabled`, `artifactory.ingress.*`) nest one level under `artifactory:` because Artifactory is a subchart here — for the standalone `artifactory` or `artifactory-ha` chart, remove that wrapper and shift `nginx.*`/`ingress.*` to chart root (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- `artifactory.ingress.className` must match a registered `IngressClass` name exactly (`kubectl get ingressclass`).

## Deploy
```bash
helm repo add nginx https://helm.nginx.com/stable
helm repo update
helm install nginx-ingress nginx/nginx-ingress --namespace nginx-ingress --create-namespace --set controller.enableSnippets=true
kubectl create secret tls artifactory-tls --cert=tls.crt --key=tls.key -n jfrog-platform
```
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f nginx-ingress-controller-platform-values.yaml
```

## Related
- [Community Controller Equivalents]: on the Kubernetes community `ingress-nginx` controller, translate every `nginx.org/` annotation above to its `nginx.ingress.kubernetes.io/` equivalent — see [ingress-annotations](../../artifactory/ingress-annotations) for that controller's annotation shape.
- [ingress-behind-load-balancer](../../artifactory/ingress-behind-load-balancer) — if this ingress controller itself sits behind another external load balancer.
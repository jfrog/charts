# Ingress Behind Another Load Balancer

This is **not an Artifactory chart value** — it's a setting on the third-party `ingress-nginx` (Kubernetes community) controller's own Helm chart. It's included here because it's a common companion to [ingress-annotations](../ingress-annotations) and [gateway-api-ingress](../gateway-api-ingress): if an external load balancer sits in front of your Ingress controller and terminates TLS or sets `X-Forwarded-*` headers, the controller needs to be told to trust and pass those headers through instead of overwriting them with the values it sees on its own listener.

See the [ingress-nginx-forwarded-headers-values.yaml](ingress-nginx-forwarded-headers-values.yaml) — a values file for the `ingress-nginx/ingress-nginx` chart, not for `jfrog/artifactory`.

## How it works
- `controller.config.use-forwarded-headers: "true"` (a string, not a boolean, per the `ingress-nginx` chart's own convention) tells the controller to trust incoming `X-Forwarded-For`/`X-Forwarded-Proto`/etc. headers from the upstream load balancer rather than setting its own based on the direct TCP connection.
- Without it, client IP logging and any Artifactory logic that inspects the originating protocol/IP sees the load balancer's address instead of the real client's.

## Deploy
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create namespace ingress-nginx
helm upgrade --install ingress-nginx --namespace ingress-nginx ingress-nginx/ingress-nginx -f ingress-nginx-forwarded-headers-values.yaml
```

Your Artifactory/jfrog-platform install itself needs no changes for this — it's entirely a setting on the Ingress controller sitting in front of it.
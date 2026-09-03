# SSL Termination at the Nginx LoadBalancer

This example terminates SSL at the Nginx `Service` (type `LoadBalancer`) rather than at an Ingress controller or the Gateway API — for example, using AWS ACM certificates attached directly to the load balancer.

See the [nginx-ssl-termination-lb-values.yaml](nginx-ssl-termination-lb-values.yaml) for the configuration example.

## How it works
- `nginx.https.enabled: false` turns off HTTPS termination inside the Nginx pod itself, since the load balancer now handles TLS.
- `nginx.service.ssloffload: true` tells the chart to still expose port 443 on the Service (routed to Nginx's plain HTTP listener) so the load balancer has an HTTPS port to terminate onto.
- The `service.beta.kubernetes.io/aws-load-balancer-*` annotations are cloud-provider-specific (shown here for AWS ACM) — the equivalent for GCP/Azure load balancers uses different annotation keys under the same `nginx.service.annotations` block.

## Deploy
```shell
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory -f nginx-ssl-termination-lb-values.yaml
```

## Notes
The same two keys (`nginx.https.enabled`, `nginx.service.ssloffload`) and annotation shape apply unchanged on `artifactory-ha`:
```shell
helm upgrade --install artifactory-ha --namespace artifactory-ha jfrog/artifactory-ha -f nginx-ssl-termination-lb-values.yaml
```

## Related
- [required-tls-nginx-secret](../required-tls-nginx-secret) — terminating TLS *inside* Nginx instead of offloading it to the load balancer.
- [ingress-behind-load-balancer](../ingress-behind-load-balancer) — a different topology: an Ingress controller (not the bundled Nginx Service) sitting behind an external load balancer.
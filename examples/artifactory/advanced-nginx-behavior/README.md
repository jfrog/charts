# Configure Advanced Nginx Behavior

The Nginx bundled with the chart covers most deployments as shipped. A handful of values change how it handles the request itself — each exists because a specific setup breaks without it: large uploads, package paths containing encoded slashes, a load balancer speaking the PROXY protocol, or an IPv6-only cluster. All default to off; turn on only the one that matches your problem.

See the [advanced-nginx-behavior-values.yaml](advanced-nginx-behavior-values.yaml) for the configuration example.

## How it works
- `nginx.disableProxyBuffering: true` streams large uploads straight through instead of buffering the request to disk on the Nginx pod first — sets `proxy_request_buffering off`, `proxy_buffering off`, and `proxy_http_version 1.1` in the generated config. The shipped sizing profiles (see [resource-sizing-profiles](../resource-sizing-profiles)) already turn this on — check before setting it by hand.
- `nginx.preserveEncodedSlashes: true` stops Nginx from decoding `%2F` in request paths before Artifactory sees them — some package types produce paths containing it, and decoding rewrites the path to the wrong artifact.
- `nginx.httpUseProxyProtocol` / `nginx.httpsUseProxyProtocol` tell Nginx to expect a PROXY protocol header from the load balancer on that listener. The two listeners are independent — set only the one your load balancer uses. Once enabled, anything connecting without the header fails, including load balancer health checks and `kubectl port-forward` — reconfigure health checks first.
- `nginx.singleStackIPv6Cluster: true` is needed on an IPv6-only cluster (where `nginx.service.ipFamilies`/`artifactory.service.ipFamilies` are IPv6-only) so Nginx also listens on and proxies over IPv6.
- `nginx.customConfigMap` / `nginx.customArtifactoryConfigMap` replace the generated `nginx.conf` / Artifactory server block entirely with your own ConfigMap — once set, every other Nginx value above stops applying and chart updates to the default configuration no longer reach you.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f advanced-nginx-behavior-values.yaml
```

## Verify
```bash
kubectl exec <nginx-pod> --namespace <namespace> -- grep -E 'proxy_buffering|proxy_protocol|merge_slashes' /etc/nginx/conf.d/artifactory.conf
```

## Related
- [advanced-nginx-behavior](../../artifactory-ha/advanced-nginx-behavior), [advanced-nginx-behavior](../../jfrog-platform/advanced-nginx-behavior) — the same settings on the HA and platform charts.
- [nginx-load-balancer-service](../nginx-load-balancer-service), [nginx-ssl-termination-lb](../nginx-ssl-termination-lb) — Nginx Service-level settings, not request-handling behavior.
- [resource-sizing-profiles](../resource-sizing-profiles) — the shipped sizing profiles already set `disableProxyBuffering` for you.

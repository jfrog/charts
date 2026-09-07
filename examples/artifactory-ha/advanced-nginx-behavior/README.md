# Configure Advanced Nginx Behavior

The Nginx bundled with the chart covers most deployments as shipped. A handful of values change how it handles the request itself — each exists because a specific setup breaks without it: large uploads, package paths containing encoded slashes, a load balancer speaking the PROXY protocol, or an IPv6-only cluster. All default to off; turn on only the one that matches your problem.

See the [advanced-nginx-behavior-values.yaml](advanced-nginx-behavior-values.yaml) for the configuration example.

## How it works
- Same keys, same flat nesting under `nginx:` as the standalone `artifactory` chart — these settings are identical across both charts.
- `nginx.disableProxyBuffering: true` streams large uploads straight through instead of buffering to disk on the Nginx pod first. The shipped sizing profiles (see [resource-sizing-profiles](../resource-sizing-profiles)) already turn this on — check before setting it by hand.
- `nginx.preserveEncodedSlashes: true` stops Nginx from decoding `%2F` in request paths before Artifactory sees them.
- `nginx.httpUseProxyProtocol` / `nginx.httpsUseProxyProtocol` tell Nginx to expect a PROXY protocol header from the load balancer on that listener. Once enabled, anything connecting without the header fails, including health checks and `kubectl port-forward` — reconfigure health checks first.
- `nginx.singleStackIPv6Cluster: true` is needed on an IPv6-only cluster so Nginx also listens on and proxies over IPv6.
- `nginx.customConfigMap` / `nginx.customArtifactoryConfigMap` replace the generated configuration entirely — once set, every other Nginx value stops applying.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f advanced-nginx-behavior-values.yaml
```

## Related
- [advanced-nginx-behavior](../../artifactory/advanced-nginx-behavior), [advanced-nginx-behavior](../../jfrog-platform/advanced-nginx-behavior) — the same settings on the standalone and platform charts.
- [resource-sizing-profiles](../resource-sizing-profiles) — the shipped sizing profiles already set `disableProxyBuffering` for you.

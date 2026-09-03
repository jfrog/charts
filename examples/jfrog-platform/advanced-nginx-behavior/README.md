# Configure Advanced Nginx Behavior

The Nginx bundled with Artifactory covers most deployments as shipped. A handful of values change how it handles the request itself — each exists because a specific setup breaks without it: large uploads, package paths containing encoded slashes, a load balancer speaking the PROXY protocol, or an IPv6-only cluster. All default to off; turn on only the one that matches your problem.

See the [advanced-nginx-behavior-values.yaml](advanced-nginx-behavior-values.yaml) for the configuration example.

## How it works
- These are all Nginx settings, so they sit under `artifactory.nginx.*` — single-nested, not double-nested like `artifactory.artifactory.*` settings (`resources`, `javaOpts`, `license`). Confirmed by rendering: `artifactory.nginx.disableProxyBuffering: true` produces `proxy_buffering off`/`proxy_request_buffering off`/`proxy_http_version 1.1` in the generated `nginx-artifactory-conf.yaml`; putting it under the double-nested path has no effect. See [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for the general rule and why this setting is an exception to it.
- `disableProxyBuffering: true` streams large uploads straight through instead of buffering to disk on the Nginx pod first. The shipped sizing profiles (see [resource-sizing-profiles](../resource-sizing-profiles)) already turn this on.
- `preserveEncodedSlashes: true` stops Nginx from decoding `%2F` in request paths before Artifactory sees them.
- `httpUseProxyProtocol` / `httpsUseProxyProtocol` tell Nginx to expect a PROXY protocol header from the load balancer on that listener. Once enabled, anything connecting without the header fails, including health checks and `kubectl port-forward`.
- `singleStackIPv6Cluster: true` is needed on an IPv6-only cluster so Nginx also listens on and proxies over IPv6.
- `customConfigMap` / `customArtifactoryConfigMap` replace the generated configuration entirely — once set, every other Nginx value stops applying.

## Deploy
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f advanced-nginx-behavior-values.yaml
```

## Related
- [advanced-nginx-behavior](../../artifactory/advanced-nginx-behavior), [advanced-nginx-behavior](../../artifactory-ha/advanced-nginx-behavior) — the standalone and HA versions of this example.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule; Nginx settings are single-nested, unlike most of Artifactory's own settings.
- [resource-sizing-profiles](../resource-sizing-profiles) — the shipped sizing profiles already set `disableProxyBuffering` for you.

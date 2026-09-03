# Configure the Nginx Service and Load Balancer

This example shows how to control how Kubernetes exposes the Nginx pod fronting an Artifactory HA cluster via `nginx.service.*` — the service type, source-IP restrictions, and traffic policy.

See the [nginx-load-balancer-service-values.yaml](nginx-load-balancer-service-values.yaml) for the configuration example.

## How it works
- Same keys and behavior as the standalone `artifactory` chart — `nginx.service.type`, `loadBalancerSourceRanges`, and `externalTrafficPolicy` are not renested for HA.
- `nginx.service.type` selects how the Nginx pod is exposed: `LoadBalancer` (default), `NodePort`, or `ClusterIP`.
- `nginx.service.externalTrafficPolicy: Local` preserves the original client source IP; the default `Cluster` distributes evenly across nodes but loses it.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f nginx-load-balancer-service-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
See [nginx-load-balancer-service](../../artifactory/nginx-load-balancer-service) for the identical configuration on the single-node `artifactory` chart.
# Configure the Nginx Service and Load Balancer

This example shows how to control how Kubernetes exposes Artifactory's Nginx pod via `nginx.service.*` — the service type, source-IP restrictions, and traffic policy.

See the [nginx-load-balancer-service-values.yaml](nginx-load-balancer-service-values.yaml) for the configuration example.

## How it works
- `nginx.service.type` selects how the Nginx pod is exposed: `LoadBalancer` (default; cloud environments provision an external LB automatically), `NodePort` (on-prem/bare-metal without a cloud LB controller), or `ClusterIP` (bring-your-own Ingress controller, no public service).
- `nginx.service.loadBalancerSourceRanges` restricts which source CIDRs can reach the load balancer — enforced as a cloud-provider firewall rule at the LB itself, regardless of `externalTrafficPolicy`.
- `nginx.service.externalTrafficPolicy: Local` (only applies when `type: LoadBalancer`) preserves the original client source IP and routes only to nodes running an Artifactory pod, instead of `Cluster` (default), which load-balances evenly across all nodes but loses the original client IP.
- `nginx.service.ssloffload: true` (not used in this example) offloads TLS termination to the load balancer itself — see [install-artifactory-and-artifactory-ha-with-nginx-and-terminate-ssl-in-nginx-service-load-balancer](../nginx-ssl-termination-lb) for that scenario.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f nginx-load-balancer-service-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also includes placeholder `nginx.tlsSecretName` — replace it with your own real TLS secret before deploying to a real cluster.

## Related
See [nginx-load-balancer-service](../../artifactory-ha/nginx-load-balancer-service) for the identical configuration on the `artifactory-ha` chart.
# Kubernetes NetworkPolicies

This example shows how to restrict pod-to-pod traffic using the chart's `networkpolicy` list, which renders one Kubernetes `NetworkPolicy` object per entry.

See the [network-policies-values.yaml](network-policies-values.yaml) for the configuration example.

## How it works
- `networkpolicy` is a chart-root list, empty by default (no NetworkPolicy objects rendered, so no traffic is restricted).
- Each entry needs a `name` and a `podSelector` (the pods it applies to); `ingress`/`egress` each take a list of rules in the same shape as the native Kubernetes `NetworkPolicySpec`.
- Omitting `podSelector`, `ingress`, or `egress` on an entry makes the chart default that field to `- {}`, which allows all traffic on that axis — be explicit rather than relying on this default.
- The example above locks PostgreSQL down to only accept inbound connections from Artifactory pods, while leaving Artifactory itself fully open — adjust the Artifactory entry's `ingress`/`egress` once you know your actual traffic sources.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f network-policies-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also sets `nginx.https.enabled: false` to skip the mandatory TLS-secret gate for this example; use a real `nginx.tlsSecretName` in production.
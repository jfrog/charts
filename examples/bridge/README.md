# JFrog Bridge

JFrog Bridge lets self-managed JPDs behind a corporate firewall participate in JFrog Platform federated services — without opening any inbound firewall rule.

Normally, federation (Access Federation, Repository Federation, Distribution to edge nodes) requires the SaaS JPD to reach the self-managed JPD directly. When the self-managed instance sits behind a firewall that blocks inbound traffic, that's not possible. Bridge solves this by reversing the connection direction: the **self-managed** side initiates an outbound TCP tunnel to the **SaaS** side, and the SaaS side then forwards traffic to the self-managed instance over that tunnel.

See the [JFrog Bridges documentation](https://docs.jfrog.com/administration/docs/jfrog-bridges) for the full solution overview, use cases, and enablement steps.

## How it works

- **Bridge Server** — runs on the SaaS side (pre-configured by JFrog).
- **Bridge Client** — deployed on the self-managed side, this chart. It opens outbound tunnels to the remote (SaaS) endpoint and forwards traffic to a local endpoint (for example, the self-managed Artifactory/Access instance).
- **Topology** — a single Bridge server can maintain tunnels with many Bridge clients (one-to-many), and multiple Bridge nodes can run for high availability. The number of open tunnels per bridge auto-scales with traffic.
- **Auth** — the client authenticates to the remote endpoint with a long-lived token scoped `system:bridge:x`, and validates the local endpoint's TLS certificate using the CA fetched from the local Access instance (or a custom one, see [client-cert](client-cert)).

This chart deploys Bridge in `client` mode.

## Examples

| Example | Description |
|---|---|
| [global-values](global-values) | Configure Bridge via the shared `global` values block (for example when deployed alongside Artifactory via `jfrog-platform`) |
| [client-cert](client-cert) | Trust a custom TLS Root CA for a bridge's local endpoint |
| [disable-cpu-limits](disable-cpu-limits) | Disable CPU limits to avoid CFS throttling on CPU-bound workloads |
| [extra-system-yaml](extra-system-yaml) | Override/extend `system.yaml` entries via `extraSystemYaml` |
| [image-digests](image-digests) | Pin images by digest instead of tag |

## Deploy

```shell
helm upgrade --install bridge jfrog/bridge \
  --set jfrogUrl=https://<your-jpd> \
  --set joinKey=<join-key> \
  --set masterKey=<master-key>
```

See the chart's [values.yaml](../../stable/bridge/values.yaml) for the full set of configuration options.

# JFrog Platform

The `jfrog-platform` chart deploys the full JFrog Platform as a single Helm release: Artifactory and Xray by default, plus optional product subcharts (Catalog, Curation, Distribution, Workers, Bridge, Wingman/MCP Server) and shared infrastructure (PostgreSQL, RabbitMQ). Every product is deployed as a subchart, so most standalone-chart values move one level deeper, nested under the subchart's name — see [platform-vs-standalone-nesting](platform-vs-standalone-nesting) for the general rule.

## Examples

### Enabling products

| Example | Description |
|---|---|
| [enable-workers](enable-workers) | Enable the JFrog Workers service (`worker` subchart + Artifactory-side wiring) |
| [enable-mission-control](enable-mission-control) | Enable Mission Control via `artifactory.mc.enabled` |
| [enable-apptrust](enable-apptrust) | Enable AppTrust, Unified Policy, Evaluation, and Compliance together |
| [enable-ai-ml](enable-ai-ml) | Enable the JFrog AI/ML frontend service via `artifactory.ml.enabled` |
| [enable-federation](enable-federation) | Enable the Artifactory Federation Service (RTFS) via `artifactory.rtfs.enabled` |
| [enable-mcp-server-wingman](enable-mcp-server-wingman) | Enable the MCP Server (`wingman` subchart) |
| [enable-advanced-security-jas](enable-advanced-security-jas) | Enable Advanced Security (JAS) on the Xray subchart |
| [enable-catalog](enable-catalog) | Enable Catalog via `catalog.enabled` (requires Xray enabled) |
| [enable-curation](enable-curation) | Enable Curation (Xray pod-split + separate route, Catalog cache, Bridge) |
| [enable-distribution](enable-distribution) | Enable Distribution via `distribution.enabled` |
| [xray-with-pod-split](xray-with-pod-split) | Deploy Xray with its services split into separate pods |
| [xray-with-catalog-valkey-cache](xray-with-catalog-valkey-cache) | Deploy Xray with Catalog using Valkey for caching |

### Licensing & credentials

| Example | Description |
|---|---|
| [license-via-secret](license-via-secret) | Supply the Artifactory license via a Kubernetes Secret |
| [postgres-password-management](postgres-password-management) | Override the bundled PostgreSQL superuser and per-product passwords |

### High availability & infrastructure

| Example | Description |
|---|---|
| [ha-via-platform-chart](ha-via-platform-chart) | Run Artifactory HA through the platform chart (`artifactory-ha` is not a subchart) |
| [HA-with-distribution-S3](HA-with-distribution-S3) | 3-node Artifactory cluster with Distribution and a direct-S3 provider |
| [openshift-overlay](openshift-overlay) | Layer custom values on top of the shipped `openshift-values.yaml` |

### TLS & networking

| Example | Description |
|---|---|
| [tls-end-to-end](tls-end-to-end) | End-to-end TLS across Artifactory, Xray, and Distribution |
| [rabbitmq-tls](rabbitmq-tls) | Enable TLS on the bundled RabbitMQ instance used by Xray |
| [custom-volumes-multi-product](custom-volumes-multi-product) | Mount custom volumes into Artifactory, Xray, Worker, and Catalog |
| [nginx-ingress-controller-platform](nginx-ingress-controller-platform) | Expose the platform through an external NGINX Ingress Controller instead of the bundled Nginx pod |

### RabbitMQ

| Example | Description |
|---|---|
| [migrate-from-classic-to-quorum-queues-for-xray](migrate-from-classic-to-quorum-queues-for-xray) | Migrate Xray's RabbitMQ from classic mirrored queues to quorum queues |
| [upgrade-to-rabbitmq-4.x](upgrade-to-rabbitmq-4.x) | Upgrade Xray's RabbitMQ to 4.x (requires quorum queues first) |
| [fresh-install-rabbitmq-4.x-with-quorum](fresh-install-rabbitmq-4.x-with-quorum) | Fresh install of Xray with RabbitMQ 4.x and quorum queues from the start |

### Upgrades & reference

| Example | Description |
|---|---|
| [upgrade-gates](upgrade-gates) | `gaUpgradeReady`/`databaseUpgradeReady` acknowledgment flags and removed-toggle pitfalls |
| [platform-vs-standalone-nesting](platform-vs-standalone-nesting) | Worked reference for translating standalone-chart values to platform-chart nesting |
| [values](values) | Additional flat `values-*.yaml` fragments (Catalog+JAS, Artifactory+Xray, external Postgres) |

## Deploy

```shell
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  --namespace jfrog-platform --create-namespace \
  -f <example>-values.yaml
```

See the chart's [values.yaml](../../stable/jfrog-platform/values.yaml) for the full set of configuration options.
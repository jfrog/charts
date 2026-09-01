# Artifactory HA

The `artifactory-ha` chart deploys a multi-node, highly available Artifactory cluster: a primary Artifactory node plus additional member nodes, fronted by nginx.

## Examples

| Example | Description |
|---|---|
| [multi-node-license](multi-node-license) | License a multi-node cluster by concatenating one Enterprise license per node into a Secret |
| [ha-resource-sizing](ha-resource-sizing) | Size the primary node's container resources and JVM heap via `artifactory.primary.*` |
| [ha-tls-setup](ha-tls-setup) | Enable internal Access CA-signed TLS and external nginx HTTPS |
| [ha-postgres-password-management](ha-postgres-password-management) | Pin the bundled PostgreSQL password instead of using the auto-generated default |
| [enable-apptrust](enable-apptrust) | Enable AppTrust, Unified Policy, Evaluation, and Compliance together |
| [enable-mission-control](enable-mission-control) | Enable Mission Control via `mc.enabled` |
| [enable-ai-ml](enable-ai-ml) | Enable the JFrog AI/ML frontend service via `ml.enabled` |
| [enable-federation](enable-federation) | Enable the Artifactory Federation Service (RTFS) via `rtfs.enabled` |
| [nginx-load-balancer-service](nginx-load-balancer-service) | Configure the Nginx Service type, source ranges, and traffic policy |
| [readonly-root-filesystem](readonly-root-filesystem) | Run the Artifactory containers with a read-only root filesystem |
| [scale-ha-cluster](scale-ha-cluster) | Scale `artifactory.primary.replicaCount`, with the Postgres-password and orphaned-PVC gotchas |
| [ha-shared-volume-claim](ha-shared-volume-claim) | Use pre-existing `ReadWriteMany` PVCs shared across all nodes |
| [ha-existing-volume-claim](ha-existing-volume-claim) | Point a primary node at its own pre-existing, non-shared PVC |
| [plugins](plugins) | Deploy Artifactory user plugins via a Kubernetes Secret |

## Deploy

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha --create-namespace
```

See the chart's [values.yaml](../../stable/artifactory-ha/values.yaml) for the full set of configuration options.
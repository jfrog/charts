# JFrog Artifactory

JFrog Artifactory is a universal artifact repository manager. This chart deploys a single-node Artifactory instance — for a multi-node HA deployment see the [artifactory-ha](../artifactory-ha) chart, and for Artifactory as part of the full JFrog Platform (alongside Xray, Catalog, Distribution, etc.) see the [jfrog-platform](../jfrog-platform) chart.

## Examples

| Example | Description |
|---|---|
| [license-via-secret](license-via-secret) | Supply the Artifactory license from a Kubernetes Secret instead of a plain-text value |
| [required-tls-nginx-secret](required-tls-nginx-secret) | Bring your own TLS Secret for the Nginx ingress, now required on fresh installs |
| [worker-enablement](worker-enablement) | Enable the Workers addon via `artifactory.worker.enabled` |
| [enable-apptrust](enable-apptrust) | Enable AppTrust, Unified Policy, Evaluation, and Compliance together |
| [enable-mission-control](enable-mission-control) | Enable Mission Control via `mc.enabled` |
| [enable-ai-ml](enable-ai-ml) | Enable the JFrog AI/ML frontend service via `ml.enabled` |
| [enable-federation](enable-federation) | Enable the Artifactory Federation Service (RTFS) via `rtfs.enabled` |
| [custom-volumes](custom-volumes) | Mount a custom volume (e.g. a trusted CA certificate) into the Artifactory container |
| [resource-jvm-sizing](resource-jvm-sizing) | Size the Artifactory container's Kubernetes resources and JVM heap together |
| [postgres-password-management](postgres-password-management) | Pin an explicit password for the bundled PostgreSQL sub-chart |
| [hpa-memory-target](hpa-memory-target) | Add a memory-utilization trigger to the Horizontal Pod Autoscaler |
| [bootstrap-artifactory](bootstrap-artifactory) | Bootstrap the `admin` user's password and allowed IP via `artifactory.admin` |
| [nginx-load-balancer-service](nginx-load-balancer-service) | Configure the Nginx Service type, source ranges, and traffic policy |
| [readonly-root-filesystem](readonly-root-filesystem) | Run the Artifactory container with a read-only root filesystem |
| [gateway-api-ingress](gateway-api-ingress) | Expose Artifactory via the Kubernetes Gateway API instead of Ingress |
| [nginx-ssl-termination-lb](nginx-ssl-termination-lb) | Terminate SSL at the Nginx LoadBalancer Service instead of inside Nginx |
| [ingress-behind-load-balancer](ingress-behind-load-balancer) | Trust forwarded headers when an Ingress controller sits behind another load balancer |
| [ingress-annotations](ingress-annotations) | Custom Ingress annotations, Docker-Registry-via-Repository-Path, and additional path rules |
| [network-policies](network-policies) | Restrict pod-to-pod traffic with the chart's `networkpolicy` list |
| [monitoring-and-logging](monitoring-and-logging) | Enable JMX monitoring and ship logs to Logstash via the Filebeat sidecar |
| [external-database-full-setup](external-database-full-setup) | Point Artifactory at an external PostgreSQL instance instead of the bundled one |
| [configmaps-non-confidential-data](configmaps-non-confidential-data) | Mount a custom `logback.xml` (or similar) via a chart-managed ConfigMap |
| [system-properties](system-properties) | Set Artifactory/Java system properties via `javaOpts` instead of `artifactory.system.properties` |
| [logging](logging) | Collect Artifactory's logs with a fluent-bit sidecar |
| [binarystore](binarystore) | Sample `binarystore.xml` templates for S3, Azure Blob, NFS, Google Storage, and cluster filesystem backends |
| [plugins](plugins) | Deploy Artifactory user plugins as a Kubernetes Secret |

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory \
  --set global.masterKey=<master-key> \
  --set global.joinKey=<join-key> \
  --set nginx.tlsSecretName=<tls-secret-name>
```

See the chart's [values.yaml](../../stable/artifactory/values.yaml) for the full set of configuration options.
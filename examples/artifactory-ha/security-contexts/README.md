# Configure Pod and Container Security Contexts

This example shows how to override the pod-level and container-level security context on Artifactory HA when a cluster policy conflicts with the chart's non-root defaults.

See the [security-contexts-values.yaml](security-contexts-values.yaml) for the configuration example.

## How it works
- Same two keys, same nesting as the standalone chart: `artifactory.podSecurityContext` (pod-level filesystem group and `runAsUser`/`runAsGroup`) and `containerSecurityContext` (chart root, per-container privilege/capabilities).
- Artifactory's default `runAsUser`/`fsGroup` is `1030` on every node in the cluster. Custom init containers or sidecars that write into the data directory must run as this same user.
- Changing `runAsUser` on an existing deployment can lock Artifactory out of its own data — files already on the persistent volume are owned by the previous user. Change `runAsUser` and `fsGroup` together, and plan a permissions fix for existing volumes.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f security-contexts-values.yaml
```

## Related
- [security-contexts](../../artifactory/security-contexts), [security-contexts](../../jfrog-platform/security-contexts) — the same two settings on the other charts.
- [openshift-overlay](../../jfrog-platform/openshift-overlay) — the chart-shipped file that disables these same contexts for every product at once, for OpenShift specifically.

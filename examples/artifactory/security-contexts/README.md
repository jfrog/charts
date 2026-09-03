# Configure Pod and Container Security Contexts

The chart runs Artifactory as a non-root user and drops container capabilities by default, so a standard Kubernetes cluster needs no security configuration at all. This example shows how to override the pod-level and container-level security context when a cluster policy conflicts with the defaults.

See the [security-contexts-values.yaml](security-contexts-values.yaml) for the configuration example.

## How it works
- `artifactory.podSecurityContext` (nested under the chart's own `artifactory:` block) owns the pod-level filesystem group and `runAsUser`/`runAsGroup`. `containerSecurityContext` (chart root) owns per-container privilege and capabilities — Artifactory is the only chart where the pod context nests under the product key; the container context does not.
- Artifactory's default `runAsUser`/`fsGroup` is `1030`. Custom init containers or sidecars that write into the data directory must run as this same user, or the write fails with a permission error.
- Setting `enabled: false` removes the security context entirely and lets the cluster decide — this is what the chart's own OpenShift overlay does (see [openshift-overlay](../../jfrog-platform/openshift-overlay), which layers a pre-built file for every product at once rather than hand-editing individual contexts like this example does).
- Changing `runAsUser` on an existing deployment can lock Artifactory out of its own data: files already on the persistent volume are owned by the previous user. Always change `runAsUser` and `fsGroup` together, and plan a permissions fix for existing volumes.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f security-contexts-values.yaml
```

## Related
- [security-contexts](../../artifactory-ha/security-contexts), [security-contexts](../../jfrog-platform/security-contexts) — the same two settings on the other charts.
- [openshift-overlay](../../jfrog-platform/openshift-overlay) — the chart-shipped file that disables these same contexts for every product at once, for OpenShift specifically.
- [readonly-root-filesystem](../readonly-root-filesystem) — a related container-hardening setting, not part of the same `podSecurityContext`/`containerSecurityContext` pair.

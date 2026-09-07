# Configure Pod and Container Security Contexts

This example shows how to override Artifactory's pod-level and container-level security context when Artifactory is deployed as a subchart of `jfrog-platform`.

See the [security-contexts-values.yaml](security-contexts-values.yaml) for the configuration example.

## How it works
- Artifactory is the only subchart that nests `podSecurityContext` under its own top-level `artifactory:` block in the standalone chart, so under `jfrog-platform` it double-nests: `artifactory.artifactory.podSecurityContext` (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)). `containerSecurityContext` sits at the standalone chart's true root, so it single-nests: `artifactory.containerSecurityContext`.
- Every other product subchart (Xray, Distribution, Catalog, Workers) keeps both `podSecurityContext` and `containerSecurityContext` single-nested under its own subchart name — Artifactory's double-nesting for `podSecurityContext` is the exception here, not the rule.
- Artifactory's default `runAsUser`/`fsGroup` is `1030`; other products use their own IDs (Xray `1035`, Distribution `1020`, Catalog `1030`, Workers `1131`). A shared volume mounted into more than one product needs a group all of them have in common.
- For OpenShift specifically, don't hand-edit these contexts — pass the chart-shipped `openshift-values.yaml` **last** on the command line instead (see [openshift-overlay](../openshift-overlay)), since OpenShift assigns its own user IDs and rejects the charts' explicit ones.
- Changing `runAsUser` on an existing deployment can lock Artifactory out of its own data — files already on the persistent volume are owned by the previous user. Change `runAsUser` and `fsGroup` together, and plan a permissions fix for existing volumes.

## Deploy
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f security-contexts-values.yaml
```

## Related
- [security-contexts](../../artifactory/security-contexts), [security-contexts](../../artifactory-ha/security-contexts) — the standalone-chart versions.
- [openshift-overlay](../openshift-overlay) — the chart-shipped file that disables these same contexts for every product at once; use that instead of this example for OpenShift.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

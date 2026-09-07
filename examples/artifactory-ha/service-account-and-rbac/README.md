# Configure a Service Account and RBAC

This example shows how to have the Artifactory HA chart create a dedicated service account and bind it to a cloud identity (IRSA on EKS, Workload Identity on GKE) for keyless access to object storage.

See the [service-account-and-rbac-values.yaml](service-account-and-rbac-values.yaml) for the configuration example.

## How it works
- Same two chart-root keys as the standalone chart: `serviceAccount` and `rbac`. Every node in the HA cluster uses the same service account.
- `serviceAccount.create: true` generates a service account named after the release, or uses `serviceAccount.name` when you supply one; `serviceAccount.annotations` carries the cloud-identity role binding.
- `serviceAccount.automountServiceAccountToken` defaults to `false` — set it to `true` for IRSA/Workload Identity, since those mechanisms need the projected token.
- **Annotations only apply to a service account the chart creates.** With `create: false`, the chart references your existing service account by `name` and never modifies it — annotations are silently ignored.
- `rbac.create: true` produces a Role/RoleBinding. Supplying `rbac.role.rules` **replaces** the default rules rather than adding to them.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f service-account-and-rbac-values.yaml
```

## Related
- [service-account-and-rbac](../../artifactory/service-account-and-rbac), [service-account-and-rbac](../../jfrog-platform/service-account-and-rbac) — the same keys on the other charts.

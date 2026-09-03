# Configure a Service Account and RBAC

Artifactory runs under the namespace's default service account unless you tell the chart otherwise. This example shows how to have the chart create a dedicated service account and bind it to a cloud identity (IRSA on EKS, Workload Identity on GKE) for keyless access to object storage.

See the [service-account-and-rbac-values.yaml](service-account-and-rbac-values.yaml) for the configuration example.

## How it works
- `serviceAccount.create` and `rbac.create` both default to `false` — nothing is created for you unless you opt in.
- `serviceAccount.create: true` generates a service account named after the release, or uses `serviceAccount.name` when you supply one. `serviceAccount.annotations` is where the cloud-identity role binding goes (e.g. `eks.amazonaws.com/role-arn` for IRSA).
- `serviceAccount.automountServiceAccountToken` defaults to `false`. Cloud identity mechanisms need the projected token, so set it to `true` when using IRSA or Workload Identity.
- **Annotations only apply to a service account the chart creates.** With `serviceAccount.create: false`, the chart references your existing service account by `name` and never modifies it — annotations set here are silently ignored, and the cloud identity binding never takes effect.
- `rbac.create: true` produces a Role and RoleBinding for the service account. Supplying `rbac.role.rules` **replaces** the chart's default rules (read access to services/endpoints/pods) rather than adding to them — include everything the deployment needs. Artifactory doesn't require these permissions for normal operation, which is why the default is `false`.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f service-account-and-rbac-values.yaml
```

## Related
- [service-account-and-rbac](../../artifactory-ha/service-account-and-rbac), [service-account-and-rbac](../../jfrog-platform/service-account-and-rbac) — the same keys on the other charts.
- [aws-marketplace-license](../aws-marketplace-license) — AWS Marketplace license redemption also needs a service account annotated for IRSA to assume the redeeming IAM role.

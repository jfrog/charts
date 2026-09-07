# Configure a Service Account and RBAC

This example shows how to have Artifactory create a dedicated service account and bind it to a cloud identity (IRSA on EKS, Workload Identity on GKE) when deployed as a subchart of `jfrog-platform`.

See the [service-account-and-rbac-values.yaml](service-account-and-rbac-values.yaml) for the configuration example.

## How it works
- Both `serviceAccount` and `rbac` sit at the standalone chart's true root (not inside its own `artifactory:` block), so under `jfrog-platform` they single-nest: `artifactory.serviceAccount` / `artifactory.rbac` — not the double `artifactory.artifactory.*` prefix that settings like `license` or `podSecurityContext` need (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)). A value placed at the wrong level is accepted by Helm and silently never applied.
- `serviceAccount.create: true` generates a service account named after the release, or uses `serviceAccount.name` when you supply one; `serviceAccount.annotations` carries the cloud-identity role binding.
- `serviceAccount.automountServiceAccountToken` defaults to `false` — set it to `true` for IRSA/Workload Identity, since those mechanisms need the projected token.
- **Annotations only apply to a service account the chart creates.** With `create: false`, the chart references your existing service account by `name` and never modifies it.
- `rbac.create: true` produces a Role/RoleBinding. Supplying `rbac.role.rules` **replaces** the default rules rather than adding to them.

## Deploy
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f service-account-and-rbac-values.yaml
```

## Related
- [service-account-and-rbac](../../artifactory/service-account-and-rbac), [service-account-and-rbac](../../artifactory-ha/service-account-and-rbac) — the standalone-chart versions.
- [aws-marketplace-license](../aws-marketplace-license) — AWS Marketplace license redemption also needs a service account annotated for IRSA.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule, including why this setting is single- not double-nested.

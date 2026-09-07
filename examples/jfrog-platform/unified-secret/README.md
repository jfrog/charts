# Unified Secret Installation

By default, each product's internal (chart-managed) secrets are consolidated into a single Kubernetes Secret instead of one Secret object per credential — `unifiedSecretInstallation` controls this, and `unifiedSecretPrependReleaseName` controls whether the release name is prepended to that Secret's name. This only affects secrets the chart itself creates and manages; it has no effect on external secrets you reference by name.

See the [unified-secret-values.yaml](unified-secret-values.yaml) for the explicit override form (useful if you need to flip one product back to per-secret installation without touching the others).

## How it works
- `jfrog-platform`'s own `values.yaml` already sets `artifactory.artifactory.unifiedSecretInstallation`, `xray.xray.unifiedSecretInstallation`, and `distribution.distribution.unifiedSecretInstallation` to `true` by default — so most installs never need to touch this.
- The double-nesting (subchart name + the standalone chart's own self-wrapped block) matches the same pattern documented in [extra-system-yaml](../extra-system-yaml): Artifactory and Distribution self-wrap their own settings in a block named after themselves, so they double-nest; a hypothetical Xray-`common`-scoped setting would not.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f unified-secret-values.yaml
```

## Related
- [unified-secret](../../artifactory/unified-secret) and [unified-secret](../../artifactory-ha/unified-secret) — the same toggle on the standalone charts, single-nested.
- [extra-system-yaml](../extra-system-yaml) — the same double-nesting pattern, verified empirically there.
- [custom-secrets](../custom-secrets) — a different secrets mechanism (user-supplied custom secrets, not the chart's own internal credential consolidation).

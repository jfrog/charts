# Control the Platform Pre-Upgrade Hook

Every `helm upgrade` of `jfrog-platform` runs a Job first, before any workload changes, as a Helm `pre-upgrade` hook at weight `-10`. It exists to stop one specific upgrade that would otherwise remove a running product without warning — if `distribution.enabled` is `false` but a Distribution pod is still running from a previous release, the Job aborts the upgrade rather than letting the product silently disappear. This example shows how to size or disable the hook.

See the [platform-pre-upgrade-hook-values.yaml](platform-pre-upgrade-hook-values.yaml) for the configuration example.

## How it works

- The hook belongs to the umbrella chart only — the standalone charts have no equivalent (though `distribution` has its own, smaller `upgradeHook` image setting).
- `preUpgradeHook.enabled` (default `true`) controls whether the Job runs at all. Disabling it also removes the Distribution guard described above.
- `preUpgradeHook.image` defaults to `bitnami/kubectl`; `preUpgradeHook.resources` defaults to `5m` CPU / `10Mi` memory requests — raise them only if the Job is being evicted or throttled on a busy node.
- `preUpgradeHook.tolerations` (default `[]`) and `preUpgradeHook.podSecurityContext.enabled` (default `false`) let the Job run on tainted nodes or under a restrictive PSA/PSP policy.
- The Job runs under its own ServiceAccount with a Role granting `get`, `list`, and `create` on `pods`/`pods/exec` in the release namespace, and reads the Artifactory unified secret (falling back to the `systemyaml` secret) to carry configuration forward across the upgrade.
- Helm removes hook Jobs on success, so check `kubectl get jobs --namespace jfrog-platform` while the upgrade is running, or read `kubectl logs job/<release>-upgrade-hook` immediately after a failure — the real reason is printed by the Job, not by Helm.

## Deploy

```console
helm upgrade jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform -f platform-pre-upgrade-hook-values.yaml
```

## Related

- [upgrade-gates](../upgrade-gates) — the `gaUpgradeReady`/`databaseUpgradeReady` acknowledgment flags this same upgrade path also enforces.
- [upgrade-blocking-chart-flags](../upgrade-blocking-chart-flags), [upgrade-blocking-chart-flags](../../artifactory/upgrade-blocking-chart-flags) — the standalone-chart flags that abort an install/upgrade outright.
- [choose-platform-products](../choose-platform-products) — the `distribution.enabled` flag this hook specifically guards against.

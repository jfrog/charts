# Add Host Entries and Extra Manifests

This example adds `/etc/hosts` entries and an extra Kubernetes manifest to an Artifactory HA release, using the same root-level `hostAliases` and `additionalResources` keys as the standalone chart.

See the [pod-networking-and-extra-resources-values.yaml](pod-networking-and-extra-resources-values.yaml) for the configuration example.

## How it works
- `hostAliases` writes entries into `/etc/hosts` on **every node in the HA cluster** — the target address must be reachable from all of them, since every replica gets the same static entries.
- `additionalResources` takes raw Kubernetes YAML rendered through Helm's `tpl`, so template expressions resolve against the release; it's created and deleted with the release's lifecycle.
- Both settings sit at chart root, same shape and same key path as the standalone `artifactory` chart — no HA-specific nesting.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f pod-networking-and-extra-resources-values.yaml
```

## Verify
```shell
kubectl exec <pod-name> --namespace artifactory-ha -c artifactory-ha -- cat /etc/hosts
```

## Related
- [pod-networking-and-extra-resources](../../artifactory/pod-networking-and-extra-resources) — the standalone-chart version.
- [pod-networking-and-extra-resources](../../jfrog-platform/pod-networking-and-extra-resources) — the jfrog-platform umbrella-chart version.

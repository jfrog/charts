# Add Host Entries and Extra Manifests

This example adds `/etc/hosts` entries and an extra Kubernetes manifest for Artifactory when it's deployed as a subchart of `jfrog-platform`.

See the [pod-networking-and-extra-resources-values.yaml](pod-networking-and-extra-resources-values.yaml) for the configuration example.

## How it works
- `artifactory.hostAliases` and `artifactory.additionalResources` are single-nested, not double — both settings sit at the standalone chart's true root (not inside its own `artifactory:` block), so they only pick up the one subchart-name prefix (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- A value placed at the wrong nesting level is silently accepted by Helm and never applied — neither setting is validated by the chart, so verify by rendering rather than guessing.
- `additionalResources` is rendered through Helm's `tpl`, so template expressions resolve against the release and can reference the subchart's own template helpers.

## Deploy
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f pod-networking-and-extra-resources-values.yaml
```

## Related
- [pod-networking-and-extra-resources](../../artifactory/pod-networking-and-extra-resources) — the standalone-chart version.
- [pod-networking-and-extra-resources](../../artifactory-ha/pod-networking-and-extra-resources) — the artifactory-ha version.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

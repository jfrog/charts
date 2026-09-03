# Set the Image Registry, Pull Secrets, and Versions

This example points a `jfrog-platform` release at a private registry, supplies pull credentials, and pins Artifactory's exact image version — all `global.*` values, applied once for the whole platform rather than per product.

See the [image-registry-and-version-pinning-values.yaml](image-registry-and-version-pinning-values.yaml) for the configuration example.

## How it works
- `global.imageRegistry`, `global.imagePullSecrets`, `global.versions`, and `global.digests` sit at the umbrella chart's own top level, exactly as on a standalone chart — `global` values are shared verbatim across every subchart, unlike product-scoped settings which need a subchart-name prefix (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- `global.versions.artifactory` pins Artifactory's tag; `global.versions` also accepts other products (`xray`, `distribution`, `router`) and individual Artifactory services (`frontend`, `observability`, `initContainers`, `filebeat`) in the same map.
- `global.imagePullSecrets` replaces every product's chart-level pull-secret list rather than merging with it — put every secret name needed by any product in this one global list.
- Only Artifactory, Artifactory HA, and Distribution honor `global.digests`; Xray, Catalog, and Workers must be pinned by tag.
- Pin the chart version too (`helm upgrade --version`) when pinning an image older than what the chart expects, so templates and image stay matched.

## Deploy
```shell
kubectl create secret docker-registry jfrog-registry \
  --docker-server=registry.example.com \
  --docker-username=<username> --docker-password=<password> \
  --namespace jfrog-platform
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f image-registry-and-version-pinning-values.yaml
```

## Verify
```shell
# List every image reference the release needs, before mirroring for an air-gapped install
helm template jfrog-platform jfrog/jfrog-platform -f image-registry-and-version-pinning-values.yaml | grep -o 'image: .*' | sort -u
```

## Related
- [image-registry-and-version-pinning](../../artifactory/image-registry-and-version-pinning), [image-registry-and-version-pinning](../../artifactory-ha/image-registry-and-version-pinning) — the standalone-chart versions.

# Set the Image Registry, Pull Secrets, and Versions

This example points an Artifactory HA release at a private registry, supplies pull credentials, and pins the exact image version, using the same `global.*` values as the standalone chart.

See the [image-registry-and-version-pinning-values.yaml](image-registry-and-version-pinning-values.yaml) for the configuration example.

## How it works
- `global.imageRegistry`, `global.imagePullSecrets`, `global.versions.artifactory`, and `global.digests.artifactory` are `global.*` values — they aren't nested under a subchart name and apply the same way as on the standalone `artifactory` chart. See [image-registry-and-version-pinning](../../artifactory/image-registry-and-version-pinning) for the full mechanism.
- `global.imagePullSecrets` replaces the chart-level pull-secret list rather than merging with it.
- Only Artifactory, Artifactory HA, and Distribution honor `global.digests` — Xray, Catalog, and Workers must be pinned by tag instead.
- Pin the chart version too (`helm upgrade --version`) when pinning an older image, so the running templates and image stay matched.

## Deploy
```shell
kubectl create secret docker-registry jfrog-registry \
  --docker-server=registry.example.com \
  --docker-username=<username> --docker-password=<password> \
  --namespace artifactory-ha
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f image-registry-and-version-pinning-values.yaml
```

## Related
- [image-registry-and-version-pinning](../../artifactory/image-registry-and-version-pinning) — the standalone-chart version, with the full mechanism explained.
- [image-registry-and-version-pinning](../../jfrog-platform/image-registry-and-version-pinning) — the jfrog-platform umbrella-chart version.

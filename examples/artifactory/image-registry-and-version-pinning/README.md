# Set the Image Registry, Pull Secrets, and Versions

Every JFrog product image is pulled from `releases-docker.jfrog.io` by default. Air-gapped and private-registry deployments need three things changed: where images come from, the credentials used to pull them, and which exact version deploys. This example shows all three via their `global.*` forms.

See the [image-registry-and-version-pinning-values.yaml](image-registry-and-version-pinning-values.yaml) for the configuration example.

## How it works
- `global.imageRegistry` mirrors every image's registry host in one place, as long as the mirror keeps the same repository paths. Two images don't follow it: Filebeat reads its own `filebeat.image.registry` (from chart `107.150.0`+), and the PostgreSQL bootstrap image reads `global.database.initContainerSetupDBImage`.
- `global.imagePullSecrets` takes a list of secret **names** as plain strings, not objects — create the Secret in the release namespace first (`kubectl create secret docker-registry ...`). It **replaces** any chart-level pull-secret list rather than merging with it — setting both silently discards the chart-level one.
- `global.versions.artifactory` pins the exact image tag. The chart resolves the tag from, in order: `global.versions.<product>`, the product's own `image.tag`, then the chart's `appVersion`. `global.versions` also accepts individual services (`frontend`, `observability`, `initContainers`, `filebeat`).
- `global.digests.artifactory` pins by immutable digest instead of a mutable tag — useful when a mirror reuses tags. Only Artifactory, Artifactory HA, and Distribution read `global.digests`; Xray, Catalog, and Workers ignore it and must be pinned by tag.
- Pinning an image **older** than the chart version isn't supported — `global.versions`/`global.digests` change the image without changing the templates, which still come from the chart. Pin the chart version too, with `helm upgrade --version`, so templates and image stay matched.

## Deploy
```shell
kubectl create secret docker-registry jfrog-registry \
  --docker-server=registry.example.com \
  --docker-username=<username> --docker-password=<password>
helm upgrade --install artifactory jfrog/artifactory -f image-registry-and-version-pinning-values.yaml
```

## Verify
```shell
# List every image reference the release needs, before mirroring for an air-gapped install
helm template artifactory jfrog/artifactory -f image-registry-and-version-pinning-values.yaml | grep -o 'image: .*' | sort -u

# Confirm the images pods actually pulled
kubectl get pods -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u
```

## Related
- [image-registry-and-version-pinning](../../artifactory-ha/image-registry-and-version-pinning), [image-registry-and-version-pinning](../../jfrog-platform/image-registry-and-version-pinning) — same `global.*` mechanism on the other charts.
- [platform-vs-standalone-nesting](../../jfrog-platform/platform-vs-standalone-nesting) — `global.*` values are shared verbatim across every subchart, unlike product-scoped settings.

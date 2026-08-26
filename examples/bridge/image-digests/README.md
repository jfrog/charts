# Bridge Image Digests

This example shows how to pin JFrog Bridge (and its sidecar/init container images) to a specific image digest, in addition to the image tag, for immutable and reproducible deployments.

Pinning by digest ensures the exact same image content is pulled every time, even if a tag is later moved to point at a different image.

See [image-digest-values.yaml](image-digest-values.yaml) for the configuration example.

## Deploy

Install Bridge with the following command:

```shell
helm upgrade --install bridge jfrog/bridge -f image-digest-values.yaml
```

## Per-image digest values

| Image | Tag value | Digest value |
|---|---|---|
| Bridge | `image.tag` | `image.digest` |
| Router | `router.image.tag` | `router.image.digest` |
| Init container (echo-mini) | `initContainers.image.tag` | `initContainers.image.digest` |
| Observability | `observability.image.tag` | `observability.image.digest` |
| Filebeat | `filebeat.image.tag` | `filebeat.image.digest` |

When both `tag` and `digest` are set for an image, the digest takes precedence when pulling the image, while the tag is still used for labeling/readability purposes.

## Digests can also be set via global values

Instead of (or in addition to) setting `digest` per image as shown above, digests can be centralized under `global.digests`. This is useful when Bridge is deployed alongside other JFrog charts (for example via the `jfrog-platform` umbrella chart) and you want a single place to pin image digests across all services.

```yaml
global:
  digests:
    bridge: sha256:bf6f9c4717b477d6b29c8d84f60ce2cee51d05804ae2e77b8ab8d6490bad25f1
    router: sha256:08e960dd2bb06be4941a2f1da18064ebe6fce54e5960c765d6208222bc03411c
    initContainers: sha256:53fdd65f79885478e083923b3f0d61cee288691984fdaa5ce44aaadd91b3414e
    observability: sha256:5fa295cad7f0c6926553bf5cf0d2fcea341db1bf519c09332a4109ca0aa4265e
    filebeat: sha256:dadb25469a97e523d8e3fc784168f303eaac444b3c72c0c8cd06245316ca0a8b
```

Order of precedence for the digest used to pull an image:

1. `global.digests.<component>`
2. `<component>.image.digest` (per-image, as shown in [image-digest-values.yaml](image-digest-values.yaml))

See the [global-values example](../global-values) for more on the `global` values block, including the equivalent `global.versions` for pinning tags.

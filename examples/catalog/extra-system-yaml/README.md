# Catalog Extra System YAML

This example shows how to add custom settings to Catalog's `system.yaml` using the `extraSystemYaml` block, without having to override the whole file.

`system.yaml` is the configuration file used internally by Catalog. The chart renders a base `system.yaml` from `files/system.yaml` and then merges anything set under `extraSystemYaml` on top of it, so you only need to specify the keys you want to add or change.

See the [extra-system-yaml-values.yaml](extra-system-yaml-values.yaml) for the configuration example.

## How it works

- `extraSystemYaml` is merged on top of the chart's base `files/system.yaml` (`extraSystemYaml` wins on conflicts).
- If a full custom `systemYaml` is also set at the chart root, that takes precedence over `files/system.yaml`, and `extraSystemYaml` is then merged on top of that instead.
- The merged result is stored as a Secret and mounted into the pod as the running `system.yaml`.

## Deploy

```shell
helm upgrade --install catalog jfrog/catalog -f extra-system-yaml-values.yaml
```

## Notes

- To fully replace `system.yaml` instead of merging into it, use `systemYamlOverride.existingSecret` to point at your own pre-created Secret with the complete file.
- `extraSystemYaml` follows the same nesting as `system.yaml` itself (`shared`, `router`, etc.).
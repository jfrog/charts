# Bridge Extra System YAML

This example shows how to add custom settings to Bridge's `system.yaml` using the `extraSystemYaml` block, without having to override the whole file.

`system.yaml` is the configuration file used internally by Bridge (and the Router it runs alongside). The chart renders a base `system.yaml` from its own templates and then merges anything set under `extraSystemYaml` on top of it, so you only need to specify the keys you want to add or change.

See the [extra-system-yaml-values.yaml](extra-system-yaml-values.yaml) for the configuration example.

## How it works

- The chart's base `system.yaml` is rendered from `files/system.yaml` (values like `router.serviceRegistry.insecure` are already wired into it as top-level chart values).
- `extraSystemYaml` is deep-merged on top of that rendered base (`extraSystemYaml` wins on conflicts), and the merged result is templated again so any `{{ ... }}` values you set are resolved.
- The final content is stored in the `<release-name>-bridge-systemyaml` Secret and mounted into the pod as `/var/opt/jfrog/bridge/etc/system.yaml`.

Because of this merge, `extraSystemYaml` can be used to:

- Add settings that have no dedicated top-level value (for example `shared.node.id` / `shared.node.ip`, or `bridge.logging.application.level`), and
- Override the value the chart would otherwise compute for an existing key (for example `router.serviceRegistry.insecure`, which is normally set from `.Values.router.serviceRegistry.insecure`).

## Deploy

Install Bridge with the following command:

```shell
helm upgrade --install bridge jfrog/bridge -f extra-system-yaml-values.yaml
```

## Notes

- `extraSystemYaml` follows the same structure as `system.yaml` itself, so nest keys under `shared`, `router`, `bridge`, etc. as they appear in the rendered file.
- If you only need to override a value the chart already exposes as a top-level setting (like `router.serviceRegistry.insecure`), prefer setting that value directly; use `extraSystemYaml` when there is no dedicated value or when adding entirely new settings.
- To fully replace `system.yaml` instead of merging into it, use `systemYamlOverride.existingSecret` (or `global.systemYamlOverride.existingSecret`) to point at your own Secret.

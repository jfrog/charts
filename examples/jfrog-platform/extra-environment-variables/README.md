# Set Environment Variables via extraEnvironmentVariables

This example shows how to inject an environment variable into Artifactory's container when it's deployed as a subchart of `jfrog-platform`, using `artifactory.artifactory.extraEnvironmentVariables`.

See the [extra-environment-variables-values.yaml](extra-environment-variables-values.yaml) for the configuration example.

## How it works
- The key is double-nested — `artifactory.artifactory.extraEnvironmentVariables` — because the standalone chart's own setting lives inside its top-level `artifactory:` block, same tier as `license`/`loggers` (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- It's a native YAML **list** of `name`/`value` pairs. Quote every value, even numeric or boolean ones.
- **Xray is the outlier**: its equivalent value is named `extraEnvVars`, not `extraEnvironmentVariables`, and it's nested under `xray.common.extraEnvVars` — plus it takes a `tpl`-rendered block-scalar **string**, not a native list. Setting `extraEnvironmentVariables` on Xray has no effect, and giving `extraEnvVars` a native list aborts the install with `wrong type for value: expected string, got []interface {}`.
- **Don't blindly override two pre-populated values**: `xray.common.extraEnvVars` already carries the block that sets Xray's RabbitMQ vhost, and `rabbitmq.extraEnvVars` already carries required Erlang scheduler arguments. Setting either replaces rather than merges — reproduce the existing block alongside your own addition, or set your variable on a single Xray service instead (e.g. `xray.analysis.extraEnvVars`).
- Distribution/Catalog/Workers each use `extraEnvironmentVariables` too, nested as `distribution.distribution.extraEnvironmentVariables`, `catalog.extraEnvironmentVariables`, and `worker.extraEnvironmentVariables` respectively (Catalog and Workers aren't double-nested, since their standalone charts don't wrap their own settings in a self-named block).

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f extra-environment-variables-values.yaml
```

## Related
- [extra-environment-variables](../../artifactory/extra-environment-variables) and [extra-environment-variables](../../artifactory-ha/extra-environment-variables) — the standalone-chart versions.
- [extra-system-yaml](../extra-system-yaml) — the alternative, more powerful method for settings that don't fit a single environment variable.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

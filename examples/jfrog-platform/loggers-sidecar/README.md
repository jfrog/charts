# Stream Log Files with Logger Sidecars

This example shows how to stream specific Artifactory log files to container stdout when Artifactory is deployed as a subchart of `jfrog-platform`, using `artifactory.artifactory.loggers`.

See the [loggers-sidecar-values.yaml](loggers-sidecar-values.yaml) for the configuration example.

## How it works
- The key is double-nested — `artifactory.artifactory.loggers` — because the standalone chart's own setting lives inside its top-level `artifactory:` block, same tier as `license`/`extraEnvironmentVariables` (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)). A value placed at the wrong nesting level is accepted by Helm and simply never applied — there's no error.
- Nginx's equivalent, for its own log files, is a separate key one level shallower under the Artifactory subchart: `artifactory.nginx.loggers`.
- Each log file name listed gets its own sidecar container, named after the log file (e.g. `artifactory-service.log` becomes the `artifactory-service-log` container). List only the logs you actually watch — each one adds a container to every Artifactory pod.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f loggers-sidecar-values.yaml
```

## Related
- [loggers-sidecar](../../artifactory/loggers-sidecar) and [loggers-sidecar](../../artifactory-ha/loggers-sidecar) — the standalone-chart versions.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

# Size Artifactory's Resources and JVM Heap

This example shows how to size the Artifactory container's Kubernetes resource requests/limits (`artifactory.resources`) together with its JVM heap (`artifactory.javaOpts.xms`/`xmx`).

See the [resource-jvm-sizing-values.yaml](resource-jvm-sizing-values.yaml) for the configuration example.

## How it works
- `artifactory.resources` sets the container's `requests`/`limits` for `cpu`/`memory`, same as any Kubernetes pod spec.
- `artifactory.javaOpts.xms`/`xmx` set the JVM's initial and maximum heap size for the Artifactory process.
- The heap max (`xmx`) should stay comfortably under `resources.limits.memory` to leave headroom for non-heap JVM memory (metaspace, thread stacks, direct buffers) and OS-level caches — sizing `xmx` at roughly 60-75% of the memory limit is a reasonable starting point.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f resource-jvm-sizing-values.yaml
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.
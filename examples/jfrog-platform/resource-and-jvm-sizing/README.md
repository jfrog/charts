# Size Artifactory's Resources and JVM Heap

This example shows how to size the Artifactory container's Kubernetes resource requests/limits together with its JVM heap when Artifactory is deployed as a subchart of `jfrog-platform`.

See the [resource-and-jvm-sizing-values.yaml](resource-and-jvm-sizing-values.yaml) for the configuration example.

## How it works
- Under `jfrog-platform`, `resources` and `javaOpts` are **double-nested**: the outer `artifactory` selects the Artifactory subchart within `jfrog-platform`'s values, and the inner `artifactory` is the standalone chart's own top-level block that `resources`/`javaOpts` live under (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for why). On the standalone `artifactory` chart, both sit at chart root; on `artifactory-ha`, they nest one level under `artifactory.primary` instead (see [resource-jvm-sizing](../../artifactory/resource-jvm-sizing) and [ha-resource-sizing](../../artifactory-ha/ha-resource-sizing)).
- `artifactory.artifactory.resources` sets the container's `requests`/`limits` for `cpu`/`memory`, same as any Kubernetes pod spec.
- `artifactory.artifactory.javaOpts.xms`/`xmx` set the JVM's initial and maximum heap size for the Artifactory process.
- `nginx.resources` and the `postgresql` subchart's own resources are **not** double-nested this way — only settings that live inside the standalone chart's own `artifactory:` block get the extra level.
- The heap max (`xmx`) should stay comfortably under `resources.limits.memory` to leave headroom for non-heap JVM memory (metaspace, thread stacks, direct buffers) and OS-level caches — sizing `xmx` at roughly 60-75% of the memory limit is a reasonable starting point.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f resource-and-jvm-sizing-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [resource-jvm-sizing](../../artifactory/resource-jvm-sizing) — the standalone-chart version of this example.
- [ha-resource-sizing](../../artifactory-ha/ha-resource-sizing) — the artifactory-ha version.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

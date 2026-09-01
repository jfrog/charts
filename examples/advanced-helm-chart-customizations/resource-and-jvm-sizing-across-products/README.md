# Resource and JVM Sizing Across Products

Sizing Artifactory's container resources and JVM heap uses a different key path depending on which chart it's deployed through — the standalone `artifactory` chart, the `artifactory-ha` chart, and the `jfrog-platform` umbrella chart each nest `resources`/`javaOpts` differently. This example lays out all three side by side.

<details>
  <summary>Artifactory</summary>

`resources` and `javaOpts` sit at chart root.

See [resource-and-jvm-sizing-artifactory-values.yaml](resource-and-jvm-sizing-artifactory-values.yaml).

```yaml
artifactory:
  resources:
    requests: { memory: "4Gi", cpu: "2" }
    limits: { memory: "8Gi", cpu: "4" }
  javaOpts:
    xms: "2g"
    xmx: "6g"
```

Deploy:
```shell
helm upgrade --install artifactory jfrog/artifactory -f resource-and-jvm-sizing-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Nested one level deeper, under `artifactory.primary`, since HA distinguishes the primary node's settings from other components (`nginx`, `frontend`, and so on — each of which has its own independent `resources` block at chart root).

See [resource-and-jvm-sizing-artifactory-ha-values.yaml](resource-and-jvm-sizing-artifactory-ha-values.yaml).

```yaml
artifactory:
  primary:
    resources:
      requests: { memory: "1Gi", cpu: "500m" }
      limits: { memory: "6Gi" }
    javaOpts:
      xms: "1g"
      xmx: "4g"
```

Deploy:
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f resource-and-jvm-sizing-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

Double-nested: the outer `artifactory` selects the Artifactory subchart within `jfrog-platform`'s values, and the inner `artifactory` is the standalone chart's own top-level block that `resources`/`javaOpts` live under (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for why). Note that `nginx.resources` and the `postgresql` subchart's resources are **not** double-nested this way — only settings that live inside the standalone chart's own `artifactory:` block get the extra level.

See [resource-and-jvm-sizing-jfrog-platform-values.yaml](resource-and-jvm-sizing-jfrog-platform-values.yaml).

```yaml
artifactory:
  artifactory:
    resources:
      requests: { memory: "4Gi", cpu: "2" }
      limits: { memory: "8Gi", cpu: "4" }
    javaOpts:
      xms: "2g"
      xmx: "6g"
```

Deploy:
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f resource-and-jvm-sizing-jfrog-platform-values.yaml
```
</details>

## Related
- [resource-jvm-sizing](../../artifactory/resource-jvm-sizing) — the narrower, artifactory-only version of this example.
- [ha-resource-sizing](../../artifactory-ha/ha-resource-sizing) — the narrower, artifactory-ha-only version.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.
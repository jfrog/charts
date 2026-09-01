# Licensing Across Products

All three charts support supplying the Artifactory license through a pre-created Kubernetes Secret rather than pasting it into values.yaml in plain text. The key name and nesting depth differ by chart, and Artifactory HA has an extra requirement — one license per cluster node.

<details>
  <summary>Artifactory (single-node)</summary>

`artifactory.license.secret` names a pre-existing Secret; `artifactory.license.dataKey` names the data key inside it holding the license file content. One license covers the single Artifactory instance.

See [licensing-artifactory-values.yaml](licensing-artifactory-values.yaml).

```shell
kubectl create secret generic artifactory-license --from-file=artifactory.lic=./artifactory.lic
helm upgrade --install artifactory jfrog/artifactory -f licensing-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA (multi-node)</summary>

Same two keys as standalone Artifactory (`artifactory.license.secret` / `artifactory.license.dataKey`) — but the mounted file must contain one Enterprise license concatenated per node, matching `artifactory.primary.replicaCount`. Resizing the cluster means resizing the license file and updating the Secret.

See [licensing-artifactory-ha-values.yaml](licensing-artifactory-ha-values.yaml).

```shell
cat license-1.lic license-2.lic license-3.lic > artifactory.cluster.license
kubectl create secret generic artifactory-cluster-license \
  --from-file=artifactory.lic=./artifactory.cluster.license \
  --namespace artifactory-ha
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f licensing-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

The same license Secret mechanism, but nested one level deeper because Artifactory is a subchart: `artifactory.artifactory.license.secret` / `artifactory.artifactory.license.dataKey` (double `artifactory.` prefix — see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) for the general rule).

See [licensing-jfrog-platform-values.yaml](licensing-jfrog-platform-values.yaml).

```shell
kubectl create secret generic artifactory-license -n jfrog-platform --from-file=artifactory.lic=./artifactory.lic
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f licensing-jfrog-platform-values.yaml
```
</details>

## References

- [artifactory/license-via-secret](../../artifactory/license-via-secret) — the narrower, single-chart version of the Artifactory tab above.
- [artifactory-ha/multi-node-license](../../artifactory-ha/multi-node-license) — the narrower, single-chart version of the Artifactory HA tab above.
- [jfrog-platform/license-via-secret](../../jfrog-platform/license-via-secret) — the narrower, single-chart version of the JFrog Platform tab above.
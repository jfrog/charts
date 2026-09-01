# Scale the HA Cluster

This example shows how to scale the number of Artifactory nodes in an `artifactory-ha` cluster via `artifactory.primary.replicaCount`, and the two things that go wrong if you scale without reading this: a misconfigured bundled PostgreSQL password, and orphaned PVCs left behind on scale-down.

See the [scale-ha-cluster-values.yaml](scale-ha-cluster-values.yaml) for the configuration example.

## How it works
- All Artifactory HA pods are primary nodes — scale with `artifactory.primary.replicaCount`, not `artifactory.node.replicaCount`. The `node`/"member node" tier from older chart versions has been consolidated: this chart's `values.yaml` only exposes an `artifactory.primary.*` block, there is no `node:` key to set (verified against `stable/artifactory-ha/values.yaml` — the doc this example is based on still mentions `artifactory.node.replicaCount`, which is outdated for the currently vendored chart).
- If the bundled PostgreSQL password was auto-generated at install time (the default — `postgresql.auth.password: ""`), you must pass the existing password on every subsequent `helm upgrade`, including scaling. Otherwise Helm regenerates a new one and Artifactory can no longer reach its own database. Retrieve it first:
  ```shell
  export DB_PASSWORD=$(kubectl get secret --namespace artifactory-ha -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}" | xargs -I{} kubectl get secret {} --namespace artifactory-ha -o jsonpath="{.data.password}" | base64 --decode)
  ```
  The chart-root key is `postgresql.auth.password` — the legacy `postgresql.postgresqlPassword` key referenced in some older docs no longer applies to this chart's bundled PostgreSQL subchart.
- Because each node is a Kubernetes StatefulSet replica, scaling **down** does not delete its PersistentVolumeClaim. The highest-ordinal PVC is left behind and must be removed manually if you don't intend to scale back up:
  ```shell
  kubectl get pvc -n artifactory-ha
  kubectl delete pvc volume-<release-name>-artifactory-ha-primary-<highest-ordinal> -n artifactory-ha
  ```

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f scale-ha-cluster-values.yaml
```

## Related
- [ha-postgres-password-management](../ha-postgres-password-management) — managing the same PostgreSQL password outside a scaling operation.
- [add-memory-target-trigger-to-artifactory-charts-using-hpa](https://jfrog.com/help/r/jfrog-installation-setup-documentation/memory-target-trigger-for-artifactory-charts-with-hpa) — scaling automatically instead of manually.
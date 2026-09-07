# Add a Custom Persistent Volume Claim

`artifactory.customPersistentVolumeClaim` adds a persistent volume to every Artifactory HA pod **alongside** its data volume, rather than replacing it. Use it for content Artifactory needs on disk that doesn't belong in the filestore — user plugin files, an import staging area, or a share several nodes read from.

See the [custom-persistent-volume-claim-values.yaml](custom-persistent-volume-claim-values.yaml) for the configuration example.

## How it works
- Same key, same flat nesting under `artifactory:` as the standalone chart — not scoped under `artifactory.primary`.
- All five fields (`name`, `mountPath`, `accessModes`, `size`, `storageClassName`) are required — the chart supplies no defaults for any of them.
- With more than one HA node, the claim needs `ReadWriteMany` and a storage class that supports it, such as NFS — `ReadWriteOnce` binds the volume to a single node and the rest of the cluster stays `Pending` with a scheduling error that doesn't mention the claim.
- The mount path must not collide with the data volume at `/var/opt/jfrog/artifactory` — mounting inside it hides the product's own directory.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-persistent-volume-claim-values.yaml
```

Verify:
```shell
kubectl get pvc --namespace artifactory-ha
kubectl exec <pod-name> --namespace artifactory-ha -c artifactory-ha -- df -h /var/opt/jfrog/artifactory-plugins
```

## Related
- [custom-persistent-volume-claim](../../artifactory/custom-persistent-volume-claim) — the standalone-chart version.
- [custom-persistent-volume-claim](../../jfrog-platform/custom-persistent-volume-claim) — the jfrog-platform umbrella-chart version.
- [ha-shared-volume-claim](../ha-shared-volume-claim) — reusing an existing claim for the *data* volume itself, a different mechanism.
- [ha-data-directories](../ha-data-directories) — pointing the HA cluster's shared data/backup directories at a path mounted this way.

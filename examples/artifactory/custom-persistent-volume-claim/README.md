# Add a Custom Persistent Volume Claim

`artifactory.customPersistentVolumeClaim` adds a persistent volume to the Artifactory pod **alongside** its data volume, rather than replacing it. Use it for content Artifactory needs on disk that doesn't belong in the filestore — user plugin files, an import staging area, or a share several pods read from.

See the [custom-persistent-volume-claim-values.yaml](custom-persistent-volume-claim-values.yaml) for the configuration example.

## How it works
- All five fields (`name`, `mountPath`, `accessModes`, `size`, `storageClassName`) are required — the chart supplies no defaults for any of them, and a claim with a field omitted is created but not mounted.
- This is a different mechanism from reusing an existing claim for the *data* volume itself (`persistence.existingClaim`) — `customPersistentVolumeClaim` is a second, independent volume next to it.
- The mount path must not collide with the data volume at `/var/opt/jfrog/artifactory` — mounting inside it hides the product's own directory.
- `ReadWriteOnce` binds the volume to a single node. With more than one Artifactory replica, only the first pod binds it and the rest stay `Pending` with a scheduling error that doesn't mention the claim — use `ReadWriteMany` with a storage class that supports it once replica count is above one (see [custom-persistent-volume-claim](../../artifactory-ha/custom-persistent-volume-claim) for the HA form).

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f custom-persistent-volume-claim-values.yaml
```

Verify:
```shell
kubectl get pvc --namespace <namespace>
kubectl exec <pod-name> --namespace <namespace> -c artifactory -- df -h /var/opt/jfrog/artifactory-plugins
```

## Related
- [custom-persistent-volume-claim](../../artifactory-ha/custom-persistent-volume-claim) — the artifactory-ha version (needs `ReadWriteMany`).
- [custom-persistent-volume-claim](../../jfrog-platform/custom-persistent-volume-claim) — the jfrog-platform umbrella-chart version.
- [ha-existing-volume-claim](../../artifactory-ha/ha-existing-volume-claim) — reusing an existing claim for the *data* volume itself, a different mechanism.
- [custom-volumes](../custom-volumes) — mounting a ConfigMap/Secret-backed volume instead of a PVC.

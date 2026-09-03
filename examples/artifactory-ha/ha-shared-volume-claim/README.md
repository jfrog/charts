# Existing Shared Volume Claim

This example shows how to point Artifactory HA's file-system-replication storage at pre-existing `ReadWriteMany` PersistentVolumeClaims — shared across every node — instead of letting the chart provision its own per-node claims, via `artifactory.persistence.fileSystem.existingSharedClaim`.

See the [ha-shared-volume-claim-values.yaml](ha-shared-volume-claim-values.yaml) for the configuration example.

## How it works
- Only applies when `artifactory.persistence.type` is `file-system` (the default), which replicates binaries across nodes rather than using an external blob store.
- `existingSharedClaim.numberOfExistingClaims` must match the number of PVCs you actually create.
- The PVCs must already exist, be `ReadWriteMany`, and match this naming convention exactly before you install/upgrade:
  ```text
  <release-name>-artifactory-ha-data-pvc-<claim-ordinal>   # e.g. myrelease-artifactory-ha-data-pvc-0, ...-data-pvc-1
  <release-name>-artifactory-ha-backup-pvc
  ```
- This is a different mechanism from [ha-existing-volume-claim](../ha-existing-volume-claim), which points each primary node at its own **non-shared** PVC — use this one specifically when you have shared storage (e.g. NAS) safe to mount from multiple nodes at once, and that one when each node needs its own independent volume.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f ha-shared-volume-claim-values.yaml
```

## Related
- [ha-existing-volume-claim](../ha-existing-volume-claim) — the non-shared, per-node equivalent.
- [binarystore](../../artifactory/binarystore) — external blob storage backends (S3, Azure Blob, GCS, NFS) as an alternative to file-system replication entirely.
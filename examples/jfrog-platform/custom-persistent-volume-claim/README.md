# Add a Custom Persistent Volume Claim

`artifactory.artifactory.customPersistentVolumeClaim` adds a persistent volume to the Artifactory pod **alongside** its data volume when Artifactory is deployed as a subchart of `jfrog-platform`. Use it for content Artifactory needs on disk that doesn't belong in the filestore — user plugin files, an import staging area, or a share several pods read from.

See the [custom-persistent-volume-claim-values.yaml](custom-persistent-volume-claim-values.yaml) for the configuration example.

## How it works
- The key is double-nested — `artifactory.artifactory.customPersistentVolumeClaim` — because the standalone chart's own setting for this key lives inside its top-level `artifactory:` block (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)). A value placed at the wrong level is accepted by Helm and never applied.
- All five fields (`name`, `mountPath`, `accessModes`, `size`, `storageClassName`) are required — the chart supplies no defaults for any of them.
- This is a different mechanism from reusing an existing claim for the *data* volume itself (`persistence.existingClaim`) — `customPersistentVolumeClaim` is a second, independent volume next to it.
- The mount path must not collide with the data volume at `/var/opt/jfrog/artifactory` — mounting inside it hides the product's own directory.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-persistent-volume-claim-values.yaml
```

Verify:
```shell
kubectl get pvc --namespace jfrog-platform
```

## Related
- [custom-persistent-volume-claim](../../artifactory/custom-persistent-volume-claim) — the standalone-chart version.
- [custom-persistent-volume-claim](../../artifactory-ha/custom-persistent-volume-claim) — the artifactory-ha version (needs `ReadWriteMany`).
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule this topic is an instance of.

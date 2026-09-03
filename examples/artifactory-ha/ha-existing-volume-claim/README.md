# Existing (Non-Shared) Volume Claim

This example shows how to point an Artifactory HA primary node at a pre-existing, node-scoped PersistentVolumeClaim via `artifactory.primary.persistence.existingClaim`, instead of letting the chart provision one automatically.

See the [ha-existing-volume-claim-values.yaml](ha-existing-volume-claim-values.yaml) for the configuration example.

## How it works
- `artifactory.primary.persistence.existingClaim: true` doesn't remove the StatefulSet's `volumeClaimTemplates` entry — it removes its `spec:` (size, access mode, storage class), leaving only the claim's name. Verified by rendering both settings: with `existingClaim: false` (default) the template includes `spec.resources.requests.storage`; with `existingClaim: true` that `spec:` block is entirely absent.
- Kubernetes only reads a StatefulSet's `volumeClaimTemplates.spec` when it needs to **provision a new** PVC. If a PVC already exists with the exact name Kubernetes expects for that pod ordinal, it binds to it instead — which is what makes this work.
- The PVC must be created first, named `volume-<release-name>-artifactory-ha-primary-<ordinal>` — e.g. `volume-myrelease-artifactory-ha-primary-0` for the first replica.
- **Chart correction**: the source documentation for this example also describes an `artifactory.node.persistence.existingClaim` variant for separate "member" nodes. That distinction no longer applies here — the currently vendored `artifactory-ha` chart has no `node:` values block at all; every replica is a primary node (`artifactory.primary.replicaCount`), so this single `primary.persistence.existingClaim` path is the only one relevant to this chart version.
- This is not the same mechanism as [ha-shared-volume-claim](../ha-shared-volume-claim) — that one mounts one `ReadWriteMany` PVC shared across every node; this one gives each node its own independent, non-shared PVC.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f ha-existing-volume-claim-values.yaml
```

## Related
- [ha-shared-volume-claim](../ha-shared-volume-claim) — the shared, `ReadWriteMany` equivalent.
- [scale-ha-cluster](../scale-ha-cluster) — scaling `artifactory.primary.replicaCount` up or down, including the matching PVC cleanup step.
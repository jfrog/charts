# Frontend, JFBus, and JFmelt Deployment Modes

Since Artifactory 7.161.x, Frontend, JFBus, and JFmelt run as standalone Kubernetes Deployments by default rather than as containers inside the Artifactory StatefulSet pod (`splitServicesToContainers: true` is now mandatory — setting it to `false` fails Helm validation outright). This topic covers reverting Frontend to in-pod mode and attaching custom volumes/mounts/env vars to the Frontend Deployment's Router and Observability sidecars, which need their own definitions separate from `artifactory.customVolumes`.

This is Artifactory/Artifactory HA only — `jfrog-platform` inherits these values unchanged through the standard `artifactory.*` single-nest prefix (same tier as `mc`/`observability`), so there's no separate platform-specific behavior to document.

<details>
  <summary>Artifactory</summary>

- `frontend.asPod` (default `true`) — set to `false` to restore Frontend as a container in the Artifactory StatefulSet pod instead of its own Deployment.
- `splitServicesToContainers` (default `true`, chart root) — `false` is no longer supported from Artifactory 7.161.x and fails the render.
- `router.customVolumes`/`customVolumeMounts`/`extraEnvironmentVariables` (also available for `frontend.*` and `observability.*`) — needed because these sidecars run in the Frontend Deployment's own pod, not the Artifactory StatefulSet pod that `artifactory.customVolumes` targets.

See [frontend-deployment-modes-artifactory-values.yaml](frontend-deployment-modes-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f frontend-deployment-modes-artifactory-values.yaml
```

> **Volume Not Found error:** `Deployment.apps is invalid: ... volumeMounts[M].name: Not found` means `router.customVolumeMounts` was set without a matching `router.customVolumes` entry using the same volume name.
</details>

<details>
  <summary>Artifactory HA</summary>

Same keys and behavior as standalone Artifactory — `frontend.asPod`, `splitServicesToContainers`, and the per-sidecar `router`/`frontend`/`observability` volume/mount/env blocks are not renamed or renested for the HA chart.

See [frontend-deployment-modes-artifactory-ha-values.yaml](frontend-deployment-modes-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f frontend-deployment-modes-artifactory-ha-values.yaml
```
</details>

## References
- [custom-volumes-across-products](../custom-volumes-across-products) — the main `artifactory.customVolumes` mechanism this topic's per-sidecar volumes are distinct from.
- [enable-disable-platform-services](../enable-disable-platform-services) — the related family of in-pod service toggles (`frontend.enabled`, `observability.enabled`, etc.), as opposed to *how* Frontend is deployed once enabled.
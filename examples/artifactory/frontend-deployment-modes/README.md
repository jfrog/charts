# Frontend, JFBus, and JFmelt Deployment Modes

Since Artifactory 7.161.x, Frontend, JFBus, and JFmelt run as standalone Kubernetes Deployments by default rather than as containers inside the Artifactory StatefulSet pod (`splitServicesToContainers: true` is now mandatory — setting it to `false` fails Helm validation outright). This example reverts Frontend to in-pod mode and attaches custom volumes/mounts/env vars to the Frontend Deployment's Router sidecar, which needs its own definitions separate from `artifactory.customVolumes`.

See the [frontend-deployment-modes-values.yaml](frontend-deployment-modes-values.yaml) for the configuration example.

## How it works

- `frontend.asPod` (default `true`) — set to `false` to restore Frontend as a container in the Artifactory StatefulSet pod instead of its own Deployment.
- `splitServicesToContainers` (default `true`, chart root) — `false` is no longer supported from Artifactory 7.161.x and fails the render.
- `router.customVolumes`/`customVolumeMounts`/`extraEnvironmentVariables` (also available for `frontend.*` and `observability.*`) — needed because these sidecars run in the Frontend Deployment's own pod, not the Artifactory StatefulSet pod that `artifactory.customVolumes` targets.

## Deploy

```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f frontend-deployment-modes-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> **Volume Not Found error:** `Deployment.apps is invalid: ... volumeMounts[M].name: Not found` means `router.customVolumeMounts` was set without a matching `router.customVolumes` entry using the same volume name.

## Related

- [frontend-deployment-modes](../../artifactory-ha/frontend-deployment-modes) — the same keys and behavior for Artifactory HA.
- [custom-volumes](../custom-volumes) — the main `artifactory.customVolumes` mechanism this topic's per-sidecar volumes are distinct from.
- [enable-disable-platform-services](../enable-disable-platform-services) — the related family of in-pod service toggles (`frontend.enabled`, `observability.enabled`, etc.), as opposed to *how* Frontend is deployed once enabled.

# Bootstrap the Artifactory Admin Password

This example shows how to bootstrap the `admin` user's password and allowed source IP at install time via `artifactory.admin`, instead of using the default `admin`/`password` credentials.

See the [bootstrap-artifactory-values.yaml](bootstrap-artifactory-values.yaml) for the configuration example.

## How it works
- `artifactory.admin.ip` restricts which source IP (or range, e.g. `"*"` for anywhere) is allowed to use these bootstrapped credentials — it does not restrict general UI/API access.
- `artifactory.admin.username`/`artifactory.admin.password` set the recreated admin account's credentials directly; alternatively `artifactory.admin.secret`/`artifactory.admin.dataKey` reference a pre-created Kubernetes Secret instead of a plaintext password.
- After applying, restart the Artifactory pod for the bootstrapped admin user to take effect (`kubectl delete pod <artifactory-pod>`).

## Deploy
```shell
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory -f bootstrap-artifactory-values.yaml
```

> The values file also includes placeholder `global.masterKey`/`global.joinKey` and `nginx.tlsSecretName` — every fresh Artifactory install requires these regardless of this example's topic.

## Related
The same `admin.ip`/`admin.username`/`admin.password` keys work identically on `artifactory-ha` (same nesting, no `primary.*` prefix needed for this particular block).
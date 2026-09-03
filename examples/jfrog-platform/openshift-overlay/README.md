# Layering Custom Values on the OpenShift Overlay

The `jfrog-platform` chart ships a ready-made `openshift-values.yaml` (available since chart 11.3.4) that disables pod/container security contexts across every product and service, since OpenShift manages pod security automatically. This example shows how to layer your own custom values on top of it correctly.

See the [openshift-overlay-values.yaml](openshift-overlay-values.yaml) for the configuration example — it's your custom values, not a copy of the shipped overlay.

## How it works

- `stable/jfrog-platform/openshift-values.yaml` in this repository is a real file shipped inside the chart itself (fetch it with `helm show values jfrog/jfrog-platform --jsonpath` or pull the chart tarball) — it isn't something you author yourself.
- Helm merges multiple `-f` files left-to-right, with later files winning on conflicting keys. Because the OpenShift overlay only touches `*SecurityContext.enabled` keys, it's safe to combine with unrelated custom values — but it must be passed **last** on the command line so its security-context settings aren't accidentally overridden by an earlier, broader file.
- This example's values file intentionally does not duplicate the shipped overlay's contents — only your own additions belong here (in this case, a custom Artifactory resource size). Deploy them together with `-f openshift-values.yaml -f openshift-overlay-values.yaml`.

## Deploy

```console
helm pull jfrog/jfrog-platform --untar
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace ./jfrog-platform \
  -f openshift-overlay-values.yaml \
  -f jfrog-platform/openshift-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Notes

- Requires `jfrog-platform` chart 11.3.4 or later — earlier versions don't ship `openshift-values.yaml`.
- If you're also enabling TLS or custom volumes (see [tls-end-to-end](../tls-end-to-end), [custom-volumes-multi-product](../custom-volumes-multi-product)), pass those files before the OpenShift overlay, not after.

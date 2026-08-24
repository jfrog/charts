# JFrog Artifactory High Availability Helm Chart

> [!NOTE]
> See the [JFrog Helm Charts README](https://github.com/jfrog/charts#container-image-migration-notice) for important notices including the container image migration.

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing, uninstalling, and deleting Artifactory. For all other information, refer to [Installing Artifactory - Helm HA Installation](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-HelmHAInstallation).

**Note:** From Artifactory 7.17.4 and above, the Helm HA installation can be installed so that each node you install can run all tasks in the cluster.

Below you will find the basic instructions for installing, uninstalling, and deleting Artifactory. For all other information, refer to the documentation site.

## Prerequisites Details

* Kubernetes 1.19+
* Artifactory HA license

## Chart Details
This chart will do the following:

* Deploy Artifactory highly available cluster. 3 primary nodes.
* Deploy a PostgreSQL database  **NOTE:** For production grade installations it is recommended to use an external PostgreSQL
* Deploy an Nginx server

## Installing the Chart

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io) to your helm client

```bash
helm repo add jfrog https://charts.jfrog.io
```
2. Next, create a unique Master Key (Artifactory requires a unique master key) and pass it to the template during installation.
3. Now, update the repository.

```bash
helm repo update
```

### Install Chart
To install the chart with the release name `artifactory`:
```bash
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha --create-namespace
```

### Nginx TLS Certificate

Starting with chart version 107.161.x, the chart no longer auto-generates the nginx TLS certificate by default. You must decide how nginx serves HTTPS.

**Fresh install** — with `nginx.https.enabled=true` (the default), the install fails unless one of the following is set:

| Option | Values flag | When to use |
|---|---|---|
| Supply your own certificate (recommended) | `--set nginx.tlsSecretName=<name>` | Production; you create a `kubernetes.io/tls` Secret out-of-band |
| Chart-generated self-signed certificate | `--set nginx.generateSelfSignedCert=true` | Dev / test only — the private key is chart-generated and not issued by a trusted CA |
| Disable HTTPS entirely | `--set nginx.https.enabled=false` | HTTP-only installs; TLS termination happens elsewhere or is not required |

To generate your own `tls.crt` / `tls.key` for the recommended option, see the JFrog documentation:
[Establish TLS in Artifactory and the JFrog Platform › Generate Certificates](https://docs.jfrog.com/installation/docs/establish-tls-in-artifactory-and-jfrog-platform#generate-certs).

Supplying your own certificate:

```bash
kubectl create secret tls artifactory-nginx-tls \
    --cert=./tls.crt --key=./tls.key -n artifactory-ha
helm upgrade --install artifactory-ha jfrog/artifactory-ha \
    --namespace artifactory-ha --create-namespace \
    --set nginx.tlsSecretName=artifactory-nginx-tls
```

**Upgrade from earlier chart versions** — if the prior release auto-generated the Secret `<release>-artifactory-ha-nginx-certificate`, this chart discovers it via `helm lookup`, reuses its `tls.crt`/`tls.key` byte-for-byte, and annotates it with `helm.sh/resource-policy: keep`. HTTPS continues to work with no operator action, and the certificate data is not modified.

The reused certificate is still self-signed by the previous chart and is not suitable for production. Replace it with your own certificate on your next upgrade:

```bash
kubectl create secret tls artifactory-nginx-tls \
    --cert=./tls.crt --key=./tls.key -n artifactory-ha
helm upgrade artifactory-ha jfrog/artifactory-ha \
    --reuse-values --set nginx.tlsSecretName=artifactory-nginx-tls
```

Once nginx is running on your certificate, the previously auto-generated Secret is retained (`helm.sh/resource-policy: keep`) and can be removed manually:

```bash
kubectl delete secret <release>-artifactory-ha-nginx-certificate -n artifactory-ha
```

If a custom certificate is supplied on the first upgrade to version 107.161.x, the legacy auto-generated Secret is deleted by Helm during that upgrade. If you plan to migrate to a custom certificate, no additional cleanup is required.

### Apply Sizing configurations to the Chart
To apply the chart with recommended sizing configurations :
For small configurations :
```bash
helm upgrade --install artifactory-ha jfrog/artifactory-ha -f sizing/artifactory-small.yaml --namespace artifactory-ha --create-namespace
```

## Uninstalling Artifactory

Uninstall is supported only on Helm v3 and on.

Uninstall Artifactory using the following command.

```bash
helm uninstall artifactory-ha && sleep 90 && kubectl delete pvc -l app=artifactory-ha
```

## Deleting Artifactory

**IMPORTANT:** Deleting Artifactory will also delete your data volumes and you will lose all of your data. You must back up all this information before deletion. You do not need to uninstall Artifactory before deleting it.

To delete Artifactory use the following command.

```bash
helm delete artifactory-ha --namespace artifactory-ha
```


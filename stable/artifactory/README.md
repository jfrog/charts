# JFrog Artifactory Helm Chart

> [!NOTE]
> See the [JFrog Helm Charts README](https://github.com/jfrog/charts#container-image-migration-notice) for important notices including the container image migration.

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing, uninstalling, and deleting Artifactory. For all other information, refer to [Installing Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-HelmInstallation).

## Prerequisites
* Kubernetes 1.19+
* Artifactory Pro trial license [get one from here](https://www.jfrog.com/artifactory/free-trial/)

## Chart Details
This chart will do the following:

* Deploy Artifactory-Pro/Artifactory-Edge (or OSS/CE if custom image is set)
* Deploy a PostgreSQL database using the stable/postgresql chart (can be changed) **NOTE:** For production grade installations it is recommended to use an external PostgreSQL.
* Deploy an optional Nginx server
* Optionally expose Artifactory with Ingress [Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Installing the Chart

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io) to your helm client

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Install Chart
To install the chart with the release name `artifactory`:
```bash
helm upgrade --install artifactory jfrog/artifactory --namespace artifactory --create-namespace
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
    --cert=./tls.crt --key=./tls.key -n artifactory
helm upgrade --install artifactory jfrog/artifactory \
    --namespace artifactory --create-namespace \
    --set nginx.tlsSecretName=artifactory-nginx-tls
```

**Upgrade from earlier chart versions** — if the prior release auto-generated the Secret `<release>-artifactory-nginx-certificate`, this chart discovers it via `helm lookup`, reuses its `tls.crt`/`tls.key` byte-for-byte, and annotates it with `helm.sh/resource-policy: keep`. HTTPS continues to work with no operator action, and the certificate data is not modified.

The reused certificate is still self-signed by the previous chart and is not suitable for production. Replace it with your own certificate on your next upgrade:

```bash
kubectl create secret tls artifactory-nginx-tls \
    --cert=./tls.crt --key=./tls.key -n artifactory
helm upgrade artifactory jfrog/artifactory \
    --reuse-values --set nginx.tlsSecretName=artifactory-nginx-tls
```

Once nginx is running on your certificate, the previously auto-generated Secret is retained (`helm.sh/resource-policy: keep`) and can be removed manually:

```bash
kubectl delete secret <release>-artifactory-nginx-certificate -n artifactory
```

If a custom certificate is supplied on the first upgrade to version 107.161.x, the legacy auto-generated Secret is deleted by Helm during that upgrade. If you plan to migrate to a custom certificate, no additional cleanup is required.

### High Availability

Note: High availability is only supported with an Artifactory Enterprise license.

To enable high availability (HA) in Artifactory, set the artifactory.replicaCount to 2 or more. A replica count of 3 is recommended for optimal performance and redundancy.

When deploying with artifactory.replicaCount > 1, avoid using artifactory.persistence.type=file-system for the filestore configuration in HA setups, as it may cause data inconsistency.

For more details on configuring the filestore, Refer [here](https://jfrog.com/help/r/jfrog-installation-setup-documentation/filestore-configuration)

```bash
# Start artifactory with 3 replicas
helm upgrade --install artifactory jfrog/artifactory --set artifactory.replicaCount=3,artifactory.persistence.type=cluster-file-system --namespace artifactory --create-namespace
```

### Apply Sizing configurations to the Chart
Note that sizings with more than one replica require an enterprise license for HA . Refer [here](https://jfrog.com/help/r/jfrog-installation-setup-documentation/high-availability)
To apply the chart with recommended sizing configurations :
For small configurations :
```bash
helm upgrade --install artifactory jfrog/artifactory -f sizing/artifactory-small.yaml --namespace artifactory --create-namespace
```

## Uninstalling Artifactory

Uninstall is supported only on Helm v3 and on.

Uninstall Artifactory using the following command.

```bash
helm uninstall artifactory && sleep 90 && kubectl delete pvc -l app=artifactory
```

## Deleting Artifactory

**IMPORTANT:** Deleting Artifactory will also delete your data volumes and you will lose all of your data. You must back up all this information before deletion. You do not need to uninstall Artifactory before deleting it.

To delete Artifactory use the following command.

```bash
helm delete artifactory --namespace artifactory
```

# JFrog Platform Helm Chart


The JFrog Platform Helm Chart provides a unified deployment solution for the JFrog DevOps Platform on Kubernetes. It orchestrates deployment of
- Platform (All JFrog products like Artifactory, Xray and others) allowing for a fully customizable and scalable environment.
- PostgreSQL database using the `bitnami/postgresql` chart (can be changed)
  
    > **Production Warning:**  This chart bundles a PostgreSQL deployment (`bitnami/postgresql`) by default. For production-grade installations, it is **highly recommended** to use an external managed PostgreSQL database (like AWS RDS or Azure Flexible Server for PostgreSQL) rather than the bundled PostgreSQL.
    >

- RabbitMQ using the `bitnami/rabbitmq` chart (can be changed)
- Optional Nginx server



> **⚠️ Important Versioning Notes**
>
>   * **GA Release:** This is the General Availability release. Backward compatibility with versions `< 10.0.0` is **not supported**.
>   * **Pipelines & Insights:** As of version `11.x`, JFrog Pipelines and Insights are decoupled from this chart. If you require these products, please utilize the `10.x` chart versions.

## 📋 Prerequisites

Ensure your environment meets the following requirements before proceeding.

| Requirement | Details |
| :--- | :--- |
| **Kubernetes** | Version `1.23` or higher. |
| **Helm**  | Helm v3 is required. |
| **License** | **Artifactory Enterprise(+)** or **Pro** license. <br> [Get a Free Trial License](https://jfrog.com/platform/free-trial/) |
| **Resources** | Sufficient CPU/RAM based on your sizing selection. For more information, see [JFrog Platform Reference Architecture Docs](https://jfrog.com/reference-architecture/). |

-----

## 🚀 Quick Start Guide



### 1\. Add the JFrog Helm Repository

Initialize your Helm client with the official JFrog repository.

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### 2\. Install the Chart

Deploy the JFrog Platform with the release name `jfrog-platform`.

```bash
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  --namespace jfrog-platform \
  --create-namespace
```

-----

## 🔴 OpenShift Deployment

For OpenShift deployments, security contexts must be disabled because OpenShift manages pod security policies automatically. An OpenShift-optimized values file (`openshift-values.yaml`) is provided that disables all security contexts for the platform's products and services.

> **📝 Note:** For additional background on OpenShift's handling of pod security, refer to [Red Hat's documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.10/html/authentication_and_authorization/managing-pod-security-policies).

### Deploying on OpenShift

To deploy JFrog Platform on OpenShift:

```bash
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  -f values.yaml \
  -f openshift-values.yaml \
  --namespace jfrog-platform \
  --create-namespace
```

> **⚠️ Important:** The `openshift-values.yaml` file **must be applied last**. When using multiple `-f` flags in Helm, later files override earlier ones. This guarantees that the OpenShift-specific settings take precedence.

### What Gets Disabled

The `openshift-values.yaml` file disables the following for all products and services deployed using this Helm chart:

- **Pod security contexts**
- **Container security contexts**

This ensures compatibility with OpenShift's built-in security model and allows the platform to operate under OpenShift's default pod security enforcement.

-----

## ⚙️ Configuration & Sizing

### Architecture & Sizing

The JFrog Platform supports various sizing tiers (Small, Medium, Large) to match your workload.

> **📝 Note:** Deployments with `replicaCount > 1` (High Availability) require an **Enterprise** or **Enterprise+** license.

**Apply a Sizing Profile:** 
To apply a pre-configured sizing profile (e.g., small), use the files found in the `sizing/` directory:

```bash
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  -f sizing/platform-small.yaml \
  --namespace jfrog-platform \
  --create-namespace
```

*Refer to the [JFrog Platform Reference Architecture](https://jfrog.com/help/r/jfrog-platform-reference-architecture/jfrog-platform-reference-architecture) for detailed resource specifications.*

### High Availability (HA) Setup

> **📝 Note:** High availability is only supported with an Artifactory Enterprise license.

For production environments requiring redundancy.

1.  **Replica Count:** Set `artifactory.artifactory.replicaCount` to 2 or more (3 is recommended).
2.  **Filestore:** **Do not** use `file-system` for persistence in HA. You must use `cluster-file-system` or an object storage provider (S3, GCS, Azure).
   
For more details on configuring the filestore, Refer [here](https://jfrog.com/help/r/jfrog-installation-setup-documentation/filestore-configuration).

<!-- end list -->

```bash
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  --set artifactory.artifactory.replicaCount=3 \
  --set artifactory.artifactory.persistence.type=cluster-file-system \
  --namespace jfrog-platform \
  --create-namespace
```

### Enabling Additional Products

This chart is modular. You can enable or disable specific products via your `customvalues.yaml`.

**Available Modules:** `Xray`, `Distribution`, `Worker`, `Catalog`, `Curation`, `JAS`.

**Example `customvalues.yaml`:**

```yaml
# Enable Distribution and Xray
distribution:
  enabled: true
xray:
  enabled: true
```

-----

## 🔑 License Management

There are three methods to apply your Artifactory license. **Choose only one method** to avoid conflicts.

### Method A: Artifactory UI or REST API (Recommended) 🖥️

Best for manual setup.

**Via UI**

1.  Deploy the chart and wait for the Artifactory pod to be `Running`.
2.  Access the Artifactory UI.
3.  Paste all license keys into the activation window. See [HA Installation & Setup](https://jfrog.com/help/r/jfrog-installation-setup-documentation/installing-artifactory)
      * *💡 Tip:* If using HA, paste all licenses at once, separated by newlines.
  

**[REST API for Licensing](https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-InstallHAClusterLicenses)**



### Method B: Kubernetes Secret (Automation) 🔐

Best for CI/CD or IaC deployments. This method is used for **initial bootstrapping only**.


1.  **Create the Secret:**
    Create a file `art.lic` containing your license keys (separated by **two** newlines).

    ```bash
    kubectl create secret generic artifactory-cluster-license --from-file=./art.lic -n jfrog-platform
    ```

2.  **Reference in `customvalues.yaml`:**

    ```yaml
    artifactory:
      artifactory:
        license:
          secret: artifactory-cluster-license
          dataKey: art.lic
    ```

> **📝 Note:** Once Artifactory is deployed, you should not keep passing these parameters as the license is already persisted into Artifactory's storage (they will be ignored). Updating the license should be done via Artifactory UI or REST API.

### Method C: Helm Value (Not Recommended for Prod) ⚠️

Pass the license directly in the values file (Caution: exposes license in plain text).

```yaml
artifactory:
  artifactory:
    license:
      licenseKey: |-
        <LICENSE_KEY_1>

        <LICENSE_KEY_2>
```

> **📝 Note:** For initial deployment only. After Artifactory starts, the license persists in storage and parameters will be ignored. Update licenses via Artifactory UI or REST API. To re-apply on each startup, use the `copyOnEveryStartup` option in `customvalues.yaml`.


-----

## ⛁ Database Management


### Upgrading Bundled PostgreSQL

**CRITICAL:** If you are upgrading the Chart and use the bundled PostgreSQL, you must pin the PostgreSQL version to match your current running version to avoid data incompatibility or restart loops.

1.  **Identify Current Version:**
    ```bash
    kubectl get pod jfrog-platform-postgresql-0 -n jfrog-platform -o jsonpath="{.spec.containers[*].image}"
    ```
2.  **Pin Version in `customvalues.yaml`:**
    Take the tag obtained above and configure it:
    ```yaml
    postgresql:
      image:
        tag: <CURRENT_POSTGRES_TAG>
    databaseUpgradeReady: true
    ```
3.  **Perform Upgrade:**
    ```bash
    helm upgrade --install jfrog-platform jfrog/jfrog-platform -f customvalues.yaml --namespace jfrog-platform --create-namespace
    ```

-----

## 🐰 RabbitMQ Quorum Queues

Xray is migrating from mirrored classic queues to **Quorum Queues**.

### Fresh Install (Quorum Enabled)

To install a fresh environment with Quorum queues enabled immediately:

```bash
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  -f rabbitmq/ha-quorum.yaml \
  --namespace jfrog-platform
```

### Migration (Existing Setup)

To migrate an existing Xray installation to Quorum queues:

```bash
helm upgrade --install jfrog-platform jfrog/jfrog-platform \
  -f rabbitmq/ha-quorum.yaml \
  -f rabbitmq/migration-to-ha-quorum.yaml \
  --namespace jfrog-platform
```

-----

## 🗑️ Uninstallation

To remove the JFrog Platform:

```bash
helm uninstall jfrog-platform --namespace jfrog-platform
```

> **📝 Note:** This command deletes the application deployments but **does not** delete the Persistent Volume Claims (PVCs) associated with your data. You must manually delete the PVCs if you wish to destroy all data.

-----

### 🔗 Useful Links

  * 🔗 [Official JFrog Helm Installation Documentation](https://www.jfrog.com/confluence/display/JFROG/Installing+the+JFrog+Platform+Using+Helm+Chart)
  * 🗄️ [Filestore Configuration](https://jfrog.com/help/r/jfrog-installation-setup-documentation/filestore-configuration)
  * 🧾 [REST API for Licensing](https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-InstallHAClusterLicenses)

-----
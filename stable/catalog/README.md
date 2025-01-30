# JFrog Catalog on Helm Chart

## Chart Details

* This Helm chart deploys JFrog Catalog micro-services.

## Prerequisites

* Kubernetes 1.19+
* Helm 3.2.0+

## Configuration

#### Installation requires a `jfrogUrl`, `joinKey` and a `masterKey`. You can pass the join key along with the Helm install / upgrade command or pass it in a values.yaml file. The following sample shows how to provide a join key in the values.yaml file.

```bash
jfrogUrl: http://art-artifactory.art:8082
joinKey: EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
masterKey: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
```

Alternatively, you can manually create secrets containing the join key and master key, and then pass them to the template during install/upgrade. The keys must be named `join-key` and `master-key`:

```bash
kubectl create secret generic joinkey-secret --from-literal=join-key=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY>
kubectl create secret generic masterkey-secret --from-literal=master-key=<YOUR_PREVIOUSLY_RETRIEVED_MASTER_KEY>
```

The following example shows the values.yaml file with the join key and master key secret.

```bash
joinKeySecretName: joinkey-secret
masterKeySecretName: masterkey-secret
```

#### You will need to provide the configurations for an external PostgreSQL database. Below is an example configuration.

```bash
database:
  url: postgres://my-postgresql:5432/catalogdb?sslmode=disable
  user: catalog
  password: catalog
```

#### The introduction of `extraSystemYaml` enables users to modify components of the `system.yaml` configuration post-template evaluation. It allows users to seamlessly customise specific aspects of the system.yaml without the need to duplicate the entire configuration file.

```bash
extraSystemYaml:
  shared:
    application:
      level: debug
```

### Final values.yaml file:

```bash
jfrogUrl: http://art-artifactory.art:8082
masterKey: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
joinKey: EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE

database:
  url: postgres://my-postgresql:5432/catalogdb?sslmode=disable
  user: catalog
  password: catalog

extraSystemYaml:
  shared:
    application:
      level: debug
```

## Installing the Chart

To install the chart with the release name `catalog`, use the following command:

```bash
helm upgrade --install catalog catalog -f custom-values.yaml
```
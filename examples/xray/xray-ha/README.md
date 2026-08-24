# Xray High Availability

This example shows how to deploy Xray in HA mode with RabbitMQ quorum queues, pre-created Kubernetes secrets, and an external PostgreSQL database.

See the [values-xray-ha.yaml](values-xray-ha.yaml) for the configuration example.

## Notes

* For HA, apply a large sizing (or larger) where `minReplicas` is at least 2. Alternatively, turn off autoscaling and set the desired `replicaCount` for Xray.
* RabbitMQ HA should use quorum and should always have 3 replicas. For more details, see the [Xray RabbitMQ Quorum Upgrade](https://docs.jfrog.com/installation/docs/xray-rabbitmq-quorum-upgrade) documentation.
* Check the affinity settings in the sizing YAML. That is important to schedule pods on different nodes.

## Create secrets

Generate and create the master key and join key secrets.
Master key can be generated separately for Xray; join key has to be taken from the Artifactory UI.

```shell
export MASTER_KEY=$(openssl rand -hex 32)
kubectl create secret generic masterkey-secret --from-literal=master-key=<your master key>
kubectl create secret generic joinkey-secret --from-literal=join-key=<your artifactory join key>
```

Create the RabbitMQ password secret:

```shell
kubectl create secret generic rabbitmq-password-secret --from-literal=rabbitmq-password='mypassword'
```

Create the external database credentials secret:

```shell
kubectl create secret generic xray-database-creds \
  --from-literal=db-url="postgres://my-postgresql:5432/xraydb?sslmode=disable" \
  --from-literal=db-user="xray" \
  --from-literal=db-password="xray"
```

Update the secret values above to match your environment before creating them.

## Deploy

Always apply a sizing file to provide the correct resources to the containers. For HA, download a large sizing configuration:

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-large.yaml \
  -o xray-large.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-xray-ha.yaml -f xray-large.yaml
```

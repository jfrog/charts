# Xray with Secrets and External Database

This example shows how to deploy Xray using pre-created Kubernetes secrets for sensitive values and an external PostgreSQL database.

See the [values-secrets-and-external-db.yaml](values-secrets-and-external-db.yaml) for the configuration example.

## Create secrets

Generate and create the master key and join key secrets:
Master key can be generated saperate for xray, join key has to be taken from the artifactoy UI.

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

Always apply a sizing file to provide the correct resources to the containers. Download a sizing configuration (for example, `xray-xsmall`):

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-xsmall.yaml \
  -o xray-xsmall.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-secrets-and-external-db.yaml -f xray-xsmall.yaml
```

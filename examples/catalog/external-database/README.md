# Catalog External Database

This example shows how to point Catalog at an existing external PostgreSQL database instead of the one bundled with `jfrog-platform`, using `database.url` and a pre-existing Kubernetes Secret for credentials.

See the [external-database-values.yaml](external-database-values.yaml) for the configuration example.

## How it works

- `database.url`, `database.user`, and `database.password` can be set as plain values, but production deployments should instead reference an existing Secret via `database.secrets.user`/`database.secrets.password`/`database.secrets.url`, each pointing at a Secret `name` and data `key`.
- When both a plain value and a `secrets` reference are set for the same field, the `secrets` reference wins.
- `database.type`/`database.driver` default to `postgresql`/`pgx` and normally don't need to change.

## Deploy

Create the credentials secret, then install:

```shell
kubectl create secret generic catalog-database-creds \
  --from-literal=db-user=<db-user> \
  --from-literal=db-password=<db-password>

helm upgrade --install catalog jfrog/catalog -f external-database-values.yaml
```
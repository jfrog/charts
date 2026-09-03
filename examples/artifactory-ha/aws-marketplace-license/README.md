# Redeem an AWS Marketplace License

This example shows how to license an Artifactory HA cluster purchased through AWS Marketplace, using a Secret holding the marketplace token and the IAM role that redeems it — instead of a license file.

See the [aws-marketplace-license-values.yaml](aws-marketplace-license-values.yaml) for the configuration example.

## How it works
- Same `aws.*` keys as the standalone chart, at chart root. The Secret needs exactly two fixed key names: `license_token` and `iam_role` — a Secret with different key names is mounted and silently ignored.
- `aws.license.enabled: true` turns on marketplace redemption; `aws.licenseConfigSecretName` names the Secret. `aws.region` defaults to `us-east-1` and must match the subscription's purchase region.
- Redemption needs outbound access to the AWS Marketplace metering service at startup — in an air-gapped or egress-restricted cluster this fails and Artifactory starts unlicensed.
- The pod also needs a service account annotated for IRSA to actually assume the IAM role — see [service-account-and-rbac](../service-account-and-rbac).

## Deploy
```shell
kubectl create secret generic artifactory-aws-license \
  --from-literal=license_token=${TOKEN} \
  --from-literal=iam_role=${ROLE_ARN} \
  --namespace artifactory-ha
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f aws-marketplace-license-values.yaml
```

## Related
- [aws-marketplace-license](../../artifactory/aws-marketplace-license), [aws-marketplace-license](../../jfrog-platform/aws-marketplace-license) — the same keys on the other charts.
- [multi-node-license](../multi-node-license) — the standard, non-Marketplace licensing path for HA (one Enterprise license per node, in a Secret).

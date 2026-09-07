# Redeem an AWS Marketplace License

An Artifactory subscription bought through AWS Marketplace isn't licensed with a license file — Artifactory redeems the entitlement at startup using a marketplace token and an IAM role, passed through a Kubernetes Secret. Use this only for AWS Marketplace purchases; a subscription bought directly from JFrog uses [a license file or Secret](../license-via-secret) instead.

See the [aws-marketplace-license-values.yaml](aws-marketplace-license-values.yaml) for the configuration example.

## How it works
- The Secret needs exactly two fixed key names: `license_token` (the marketplace token) and `iam_role` (the ARN of the role permitted to redeem it). A Secret with different key names is mounted and then silently ignored — the chart looks for those two names specifically.
- `aws.license.enabled: true` turns on marketplace redemption; `aws.licenseConfigSecretName` names the Secret created above.
- `aws.region` defaults to `us-east-1` and must match the region where the marketplace subscription was purchased — a mismatch fails redemption even when the token is valid.
- Redemption needs outbound network access to the AWS Marketplace metering service at startup. In an air-gapped or egress-restricted cluster this call fails and Artifactory starts unlicensed — allow egress to the marketplace endpoint for the configured region, or use a license file instead.
- The pod also needs to actually assume the IAM role, which in practice means a service account annotated for IRSA — see [service-account-and-rbac](../service-account-and-rbac).

## Deploy
```shell
kubectl create secret generic artifactory-aws-license \
  --from-literal=license_token=${TOKEN} \
  --from-literal=iam_role=${ROLE_ARN}
helm upgrade --install artifactory jfrog/artifactory -f aws-marketplace-license-values.yaml
```

## Related
- [aws-marketplace-license](../../artifactory-ha/aws-marketplace-license), [aws-marketplace-license](../../jfrog-platform/aws-marketplace-license) — the same keys on the other charts.
- [license-via-secret](../license-via-secret) — the standard, non-Marketplace licensing path (a license file in a Secret, rather than a marketplace token).
- [service-account-and-rbac](../service-account-and-rbac) — annotating the service account for IRSA so the pod can actually assume the redeeming IAM role.

# Redeem an AWS Marketplace License

This example shows how to license Artifactory with an AWS Marketplace subscription when deployed as a subchart of `jfrog-platform`, using a Secret holding the marketplace token and the IAM role that redeems it — instead of a license file.

See the [aws-marketplace-license-values.yaml](aws-marketplace-license-values.yaml) for the configuration example.

## How it works
- `aws.*` sits at the standalone chart's true root (not inside its own `artifactory:` block), so under `jfrog-platform` it single-nests: `artifactory.aws.*` — not the double `artifactory.artifactory.*` prefix that settings like `license` need (see [platform-vs-standalone-nesting](../platform-vs-standalone-nesting)).
- The Secret needs exactly two fixed key names: `license_token` and `iam_role` — a Secret with different key names is mounted and silently ignored.
- `aws.license.enabled: true` turns on marketplace redemption; `aws.licenseConfigSecretName` names the Secret. `aws.region` defaults to `us-east-1` and must match the subscription's purchase region.
- Redemption needs outbound access to the AWS Marketplace metering service at startup — in an air-gapped or egress-restricted cluster this fails and Artifactory starts unlicensed.
- The pod also needs a service account annotated for IRSA to actually assume the IAM role — see [service-account-and-rbac](../service-account-and-rbac).

## Deploy
```shell
kubectl create secret generic artifactory-aws-license -n jfrog-platform \
  --from-literal=license_token=${TOKEN} \
  --from-literal=iam_role=${ROLE_ARN}
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f aws-marketplace-license-values.yaml
```

## Related
- [aws-marketplace-license](../../artifactory/aws-marketplace-license), [aws-marketplace-license](../../artifactory-ha/aws-marketplace-license) — the standalone-chart versions.
- [license-via-secret](../license-via-secret) — the standard, non-Marketplace licensing path.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule, including why this setting is single- not double-nested.

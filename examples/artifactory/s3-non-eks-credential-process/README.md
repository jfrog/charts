# S3-compatible storage with live-swapped credentials (non-EKS)

This example is for a Kubernetes cluster that is **not EKS** — no IRSA
(IAM Roles for Service Accounts) and no EC2 instance profile available to
hand Artifactory AWS credentials automatically — deploying Artifactory
against an **S3-compatible** object store where OIDC / AssumeRoleWithWebIdentity
isn't available either.

When a native workload-identity option is available, prefer it instead: EKS
Pod Identity or IRSA for AWS S3, or OIDC / AssumeRoleWithWebIdentity for
S3-compatible backends (e.g. MinIO, Ceph) that support it. This example
covers the case where none of those are available, and short-lived
credentials instead need to come from a `credential_process` — a script the
AWS SDK invokes on its own each time the current token nears expiry, giving
a live swap of credentials with no pod restart.

This example assumes that secure endpoint already exists and returns a JSON
document in exactly the shape the AWS SDK expects (see
[credential-process/get-s3-credentials.sh](credential-process/get-s3-credentials.sh)).
Building that endpoint is outside the scope of this example — though the
script that calls it could just as easily call something like HashiCorp
Vault instead, as long as it still prints the same JSON shape to stdout.

## The AWS SDK v2 / JVM keystore issue

There is a currently-known issue where the AWS SDK v2 (`awsS3V3.awsSdkV2: true`
below — used by Artifactory's `s3-storage-v3` binary provider) bypasses the
JVM keystore/truststore for TLS verification of HTTPS endpoints, and instead
relies on the pod's **OS-level** trust store. That means a custom/private CA
has to be trusted in two separate places for this to work end-to-end:

1. **JVM truststore** — via the chart's built-in `artifactory.customCertificates`
   (used by Artifactory's own Java code paths).
2. **OS truststore** — via a custom init container that runs `update-ca-trust`,
   following JFrog's documented procedure for [adding custom SSL certificates to an Artifactory pod using Helm charts](https://jfrog.com/help/r/artifactory-how-to-add-custom-ssl-certificates-to-an-artifactory-pod-using-helm-charts/artifactory-how-to-add-custom-ssl-certificates-to-an-artifactory-pod-using-helm-charts).
   This is what the AWS SDK itself relies on, and also what makes `curl`
   (used by the `credential_process` script) trust the secure token endpoint
   without any extra flags.

Both are configured in [values-s3-non-eks-credential-process.yaml](values-s3-non-eks-credential-process.yaml)
— you only need to supply the certificate and edit the storage settings
described below.

## What's in this example

```
s3-non-eks-credential-process/
├── values-s3-non-eks-credential-process.yaml   # the Helm values
└── credential-process/
    ├── config                                # AWS profile (credential_process)
    └── get-s3-credentials.sh                 # calls the secure endpoint
```

## Steps

1. **Edit the storage settings.** In
   [values-s3-non-eks-credential-process.yaml](values-s3-non-eks-credential-process.yaml),
   under `artifactory.persistence.awsS3V3`, edit `endpoint`, `bucketName`,
   `path` and `region` for your S3-compatible backend. If your backend
   requires path-style bucket addressing, uncomment `enablePathStyleAccess:
   true`. The chart generates `binarystore.xml` from these values — no
   manual XML or Secret needed for this part.

2. **Create the CA certificate secret.** Put your S3-compatible endpoint's
   (and secure token endpoint's, if different) CA certificate in a file
   named `tls.crt` — the chart's `customCertificates` init logic looks for
   any non-`.key` file in this secret and treats a file named `tls.crt`
   specially (renaming it to `ca.crt`), so `tls.crt` is the simplest name to
   use:

   ```bash
   kubectl -n artifactory create secret generic s3-secret \
     --from-file=tls.crt=./ca.crt
   ```

3. **Create the AWS credential_process secret.** This bundles the AWS
   profile config and the script that calls your secure token endpoint:

   ```bash
   kubectl -n artifactory create secret generic s3-credential-process \
     --from-file=config=./credential-process/config \
     --from-file=get-s3-credentials.sh=./credential-process/get-s3-credentials.sh
   ```

4. **Edit the values file.** In
   [values-s3-non-eks-credential-process.yaml](values-s3-non-eks-credential-process.yaml),
   set `SECURE_TOKEN_ENDPOINT_URL` to your real secure endpoint URL.

5. **Supply the mandatory Master Key / Join Key and install.** This chart
   requires these on every install regardless of this example's feature:

   ```bash
   export MASTER_KEY=$(openssl rand -hex 32)
   export JOIN_KEY=$(openssl rand -hex 32)

   helm upgrade --install artifactory --namespace artifactory jfrog/artifactory \
     -f values-s3-non-eks-credential-process.yaml \
     --set global.masterKey=${MASTER_KEY} \
     --set global.joinKey=${JOIN_KEY}
   ```

   For a real deployment, use pre-existing Secrets for the keys instead —
   see the [master-join-key-secrets](../master-join-key-secrets) example.
   Note this chart also requires an nginx TLS certificate on install
   (`nginx.tlsSecretName` or `nginx.generateSelfSignedCert: true`), which
   this example does not set — supply it based on how you're exposing
   Artifactory (see the [ingress-tls](../ingress-tls) example).

## Notes

- The `update-ca-trust` init container runs as root with
  `privileged: true` — this matches the escalation level JFrog's own
  documented procedure uses to update the OS trust store; it is scoped to a
  short-lived init container, not the long-running Artifactory process.
- If the secure token endpoint ever returns something other than the exact
  JSON shape the AWS SDK expects (see comments in
  [get-s3-credentials.sh](credential-process/get-s3-credentials.sh)), the
  SDK will fail credential resolution entirely — there's no partial/fallback
  behavior.
- Watch `Expiration` on the tokens your endpoint issues: if it's too short
  relative to how long an individual upload/download can take, in-flight S3
  operations can fail credential validation mid-transfer.

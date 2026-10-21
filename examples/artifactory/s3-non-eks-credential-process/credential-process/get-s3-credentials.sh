#!/bin/sh
# AWS credential_process helper: fetches short-lived S3-compatible storage
# credentials from a secure internal endpoint and prints them to stdout in
# the JSON shape the AWS SDK expects. The SDK's ProcessCredentialsProvider
# calls this script again on its own once the returned "Expiration" time
# approaches, giving continuous credential rotation with no restart.
#
# This assumes SECURE_TOKEN_ENDPOINT_URL already returns a JSON document of
# the form:
#   {
#     "Version": 1,
#     "AccessKeyId": "...",
#     "SecretAccessKey": "...",
#     "SessionToken": "...",
#     "Expiration": "2026-01-01T00:00:00Z"
#   }
#
# TLS trust for this endpoint (and for the S3-compatible storage endpoint
# itself) relies on the custom CA having been added to the pod's OS trust
# store by the update-ca-trust init container — see values.yaml.

set -eu

if [ -z "${SECURE_TOKEN_ENDPOINT_URL:-}" ]; then
  echo "SECURE_TOKEN_ENDPOINT_URL is not set" >&2
  exit 1
fi

curl -sf --max-time 10 "${SECURE_TOKEN_ENDPOINT_URL}"

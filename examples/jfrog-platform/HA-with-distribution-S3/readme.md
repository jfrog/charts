## 3-Node Artifactory Cluster with Distribution and direct-S3 Provider

### Overall
| Product   | Enabled   |
|-------------|-------------|
| Artifactory      | ✅      |
| xray | ❌ |
| distribution | ✅ |
| insight | ❌ |
| pipelines | ❌ |
| worker | ❌ |


### Artifactory
| Detail   | Value    |
|-------------|-------------|
| Replica      | 3      |
| Database | External Postgres |
| Persistence | Default Storage Class + S3 |
| SSL | ✅ |
| Ingress | ❌ |
| Nginx Deployment | ✅ |
| UnifiedSecret | ✅ |
| Non-Default Admin Credential | ✅ |
| Default Master Key |  ❌ |
| Sizing Parameters | artifactory-xlarge |
| Private Registry | ✅ |


### Distribution

| Detail   | Value    |
|-------------|-------------|
| Replica      | 2       |
| Database | External Postgres |
| Persistence | Default Storage Class |
| External redis | ❌ |
| SSL | ✅ |
| UnifiedSecret | ❌ |
| Sizing Parameters | distribution-xlarge |
| Private Registry | ✅ |


Note: This requires distribution chart 102.23.0+ to work, which comes default with platform chart 10.17.4+.


## Install

1. In values-main.yaml, add your Artifactory hostname as jfrogUrl.

2. To pull images from a private registry, create your own imagePullSecrets and fill in imagePullSecrets and imageRegistry in values-main.yaml:
   
  $ kubectl create secret docker-registry regsecret --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>

3. Passing secret: 
  
  If you want to change the secret name, remember to update the reference in values-main or values-artifactory

  a. Master Key

  $ kubectl create secret generic my-master-key --from-literal=master-key="$(openssl rand -hex 32)" -n <namespace>

  b. Join Key
  
  $ kubectl create secret generic my-join-key --from-literal=join-key="$(openssl rand -hex 32)" -n <namespace>

  c. CA Certificate for SSL
  
  Passing your own ca.crt for artifactory if needed for ssl configuration. See prerequisite for ca.crt. [here](https://jfrog.com/help/r/jfrog-installation-setup-documentation/prerequisites-for-custom-tls-certificate) 

  $ kubectl create secret tls my-cacert --cert=ca.crt --key=ca.private.key -n <namespace>

  d. Default Admin Credentials

  $ kubectl create secret generic my-admin --from-literal=bootstrap.creds="$(printf "%s@%s=%s" admin 127.0.0.1 password| base64 )" -n <namespace>

4. Fill in database details ( values-artifactory.yaml ). [See here for more details related to database.](https://jfrog.com/help/r/jfrog-installation-setup-documentation/database-configuration)

  $ kubectl create secret generic my-database --from-literal=db-url='database_url' --from-literal=db-user='admin_user' --from-literal=db-password='password' -n <namespace>
  $ kubectl create secret generic my-distribution-database --from-literal=db-url='database_url' --from-literal=db-user='admin_user' --from-literal=db-password='password' -n <namespace>

5. Create the binarystore.xml secrect or pull the values from environment variables. 
   
   $  kubectl create secret generic my-binarystore --from-file=binarystore.xml
   
   To use IAM roles, check [here](https://jfrog.com/help/r/artifactory-how-to-configure-an-aws-s3-object-store-using-an-iam-role-instead-of-an-iam-user/artifactory-how-to-configure-an-aws-s3-object-store-using-an-iam-role-instead-of-an-iam-user)

6. Pull charts ( if you need to reference the suggested sizing paramerters ) and install 


```
$ helm repo update
$ helm pull jfrog/jfrog-platform --untar
```


```
$ helm install <name> jfrog/jfrog-platform -n <namespace> -f values-main.yaml -f values-artifactory.yaml -f values-distribution.yaml -f jfrog-platform/charts/artifactory/sizing/artifactory-xlarge.yaml -f jfrog-platform/charts/distribution/sizing/distribution-xlarge.yaml
```

7. If you are installing on openshift, add values-openshift.yaml
  
```
$ helm install <name> jfrog/jfrog-platform -n <namespace> -f values-main.yaml -f values-artifactory.yaml -f values-distribution.yaml -f values-openshift.yaml -f jfrog-platform/charts/artifactory/sizing/artifactory-xlarge.yaml -f jfrog-platform/charts/distribution/sizing/distribution-xlarge.yaml
```

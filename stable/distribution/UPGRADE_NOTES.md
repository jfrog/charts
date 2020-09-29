# JFrog Distribution Chart Upgrade Notes
This file describes special upgrade notes needed at specific versions

## Upgrade from 3.x to 5.x and above (Chart Versions)

* If this is a new deployment or you already use an external database (`postgresql.enabled=false`), these changes **do not affect you!**
* To upgrade from a version prior to 3.x, you first need to upgrade to latest version of 3.x as described in https://github.com/jfrog/charts/blob/master/stable/distribution/CHANGELOG.md.

**DOWNTIME IS REQUIRED FOR AN UPGRADE!**
* PostgreSQL sub chart was upgraded to version `7.x.x`. This version is not backward compatible with the old version (`0.9.5`)!
* Note the following **PostgreSQL** Helm chart changes
  * The chart configuration has changed! See [values.yaml](values.yaml) for the new keys used
  * **PostgreSQL** is deployed as a StatefulSet
  * See [PostgreSQL helm chart](https://hub.helm.sh/charts/stable/postgresql) for all available configurations
* Upgrade
  * Due to breaking changes in the **PostgreSQL** Helm chart, a migration of the database is needed from the old to the new database
  * The recommended migration process is full DB export and import of Postgresql
    * Upgrade steps:
     1. Prerequisite step to get details of existing chart.\
       a. Block user access to Distribution (do not shutdown).\
       b. Obtain the service name (OLD_PG_SERVICE_NAME) of the existing postgresql pod using below command\
          Example : OLD_PG_SERVICE_NAME value is `<OLD_RELEASE_NAME>-postgresql`
          ```bash
          $ kubectl get svc
          NAME                                        TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
          <OLD_RELEASE_NAME>-distribution              LoadBalancer   10.111.81.201    <pending>     80:31272/TCP                  50m
          <OLD_RELEASE_NAME>-postgresql                ClusterIP      10.97.121.27      <none>       5432/TCP                      50m
          ```
        c. Keep the previous password (OLD_PASSWORD) or Extract it from the secret of the existing postgresql pod.\
          Example :
          ```bash
          $ OLD_PASSWORD=$(kubectl get secret -n <namespace> <OLD_RELEASE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
          ```
     2. Install the new Distribution version with 0 replicas.\
         a. New PostgreSQL pod will be deployed and started. Distribution pod will be deployed but not started as the replica count is 0.\
         Example :
         ```bash
         $ helm install distribution-new --set replicaCount=0 --set distribution.jfrogUrl=<ARTIFACTORY_URL> --set postgresql.postgresqlPassword=<password> --set redis.password=<password> --set distribution.joinKey=<JOIN_KEY> jfrog/distribution
         ``` 
         b. Connect to the new PostgreSQL pod (you can obtain the name by running kubectl get pods):
           ```bash
           $ kubectl exec -it <NAME> bash
           ```
         c. Once logged in, create a dump file from the previous database using pg_dump, connect to previous postgresql chart:
           ```bash
           $ pg_dump -h <OLD_PG_SERVICE_NAME> -U distribution <DATABASE_NAME> > /tmp/backup.sql
           ```
         d. After you ran above command you should be prompted for a password, this password is the previous chart password (OLD_PASSWORD). This operation could take some time depending on the database size.
         e. Once you have the backup file, you can restore it with a command like the one below:
          ```bash
          $ psql -U distribution <DATABASE_NAME> < /tmp/backup.sql
          ```
         f. After ran above command you should be prompted for a password, this is current chart password.This operation could  take some time depending on the database size.
      3. Run `helm upgrade` which brings up distribution
         &nbsp;Example :
         ```bash
         $ helm upgrade --install distribution-new --set distribution.jfrogUrl=<ARTIFACTORY_URL> --set postgresql.postgresqlPassword=<password> --set redis.password=<password> --set distribution.joinKey=<JOIN_KEY> --set distribution.migration.enabled=true jfrog/distribution
         ```
      4. Restore access to distribution
      5. Run `helm delete <OLD_RELEASE_NAME>` which will remove  old Distribution deployment and Helm release.
    * Distribution should now be ready to get back to normal operation

## Upgrade from 4.x to 5.x and above (Chart Versions)

* JFrog Distribution v2.x is only compatible with JFrog Artifactory v7.x and To upgrade, you must first install JFrog Artifactory 7.x
* It is recommended to upgrade to the latest available chart versions. **Important** All the breaking changes should be resolved manually, see [changelog](https://github.com/jfrog/charts/blob/master/stable/distribution/CHANGELOG.md).

* Upgrading to 7.x (chart version)
  * Upgrade steps:
    1. Delete the existing service and statefulset of distribution.
       ```bash
       $ kubectl delete statefulsets <OLD_RELEASE_NAME>-distribution
       $ kubectl delete services <OLD_RELEASE_NAME>-distribution
       ```    
    2. If you are using the default PostgreSQL (postgresql.enabled=true), you need to pass previous 9.x or 10.x's postgresql.image.tag and databaseUpgradeReady=true, also should delete the existing statefulset of postgresql subchart before helm upgrade since 9.x chart version of postgresql has breaking changes, see [9.x Upgrade Notes](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#900)
    3. Run `helm upgrade` with the following values set
       ```bash
       $ helm upgrade distribution --set databaseUpgradeReady=true --set unifiedUpgradeAllowed=true --set postgresql.postgresqlPassword=<old password> --set postgresql.image.tag=<old image tag> --set redis.password=<old password> --set distribution.joinKey=<JOIN_KEY> --set distribution.jfrogUrl=<ARTIFACTORY_URL> --set distribution.masterKey=<old master key> --set distribution.migration.enabled=true jfrog/distribution
       ```

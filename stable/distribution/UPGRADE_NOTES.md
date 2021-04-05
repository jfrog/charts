# JFrog distribution Chart Upgrade Notes
This file describes special upgrade notes needed at specific versions

## Upgrade from 3.x to 4.X (Chart Versions)

* To upgrade from a version prior to 3.x, you first need to upgrade to latest version of 3.x as described in https://github.com/jfrog/charts/blob/master/stable/distribution/CHANGELOG.md.

**DOWNTIME IS REQUIRED FOR AN UPGRADE!**
* PostgreSQL sub chart was upgraded to version `8.x.x`. This version is not backward compatible with the old version (`0.9.5`)!
* Note the following **PostgreSQL** Helm chart changes
  * The chart configuration has changed! See [values.yaml](values.yaml) for the new keys used
  * **PostgreSQL** is deployed as a StatefulSet
  * See [PostgreSQL helm chart](https://hub.helm.sh/charts/stable/postgresql) for all available configurations
* Upgrade
  * Due to breaking changes in the **PostgreSQL** Helm chart, a migration of the database is needed from the old to the new database
  * The recommended migration process is Full DB export and import of Postgresql
    * Upgrade steps:
      1. Prerequisite step to get details of existing chart\
       a. Block user access to Distribution (do not shutdown).\
       b. Obtain the service name (OLD_PG_SERVICE_NAME) using below command\
          Example: OLD_PG_SERVICE_NAME value is `<OLD_RELEASE_NAME>-postgresql`
          ```bash
          $ kubectl get svc
          NAME                                       TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
          <OLD_RELEASE_NAME>-postgresql              ClusterIP      10.101.250.74    <none>        5432/TCP                      114m
          <OLD_RELEASE_NAME>-distribution            ClusterIP      10.101.250.89    <none>        80:30291/TCP                  113m
         ```
         c. Keep the previous password (OLD_PG_PASSWORD) or Extract it from the secret of the existing postgresql pod
          Example: 
          ```bash
          OLD_PG_PASSWORD=$(kubectl get secret -n <namespace> <OLD_RELEASE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
          ```
         d. Stop old Distribution pod (scale down replicas to 0). Postgresql still exists
          ```bash
          $ kubectl scale statefulsets <REPLACE_OLD_RELEASE_NAME>-distribution --replicas=0
          ```
      2. Run the `helm install` with the `new version` say `distribution-new` with distribution scale down replicas to 0.
          Example:
          ```bash
          helm install distribution-new --set replicaCount=0 jfrog/distribution
          ```
      3. To Migrate Postgresql data between old and new pods\
          a. Connect to the new PostgreSQL pod (you can obtain the name by running kubectl get pods)
           ```bash
           $ kubectl exec -it <NAME> bash
           ```
          b. Once logged in, create a dump file from the previous database using pg_dump, connect to previous postgresql chart:\
           ```bash
           $ pg_dump -h <OLD_PG_SERVICE_NAME> -U distribution DATABASE_NAME > /tmp/backup.sql
           ```
          c. After you ran above command you should be prompted for a password, this password is the previous chart password (OLD_PG_PASSWORD). This operation could take some time depending on the database size.\
          d. Once you have the backup file, you can restore it with a command like the one below:\
            ```bash
            $ psql -U distribution DATABASE_NAME < /tmp/backup.sql
            ```
          e. After run above command you should be prompted for a password, this is the current chart password.This operation could  take some time depending on the database size.
      5. Run the Upgrade final time which would start distribution with `databaseUpgradeReady=true` \
         Example :
         ```bash
         helm upgrade --install distribution-new --set replicaCount=1,databaseUpgradeReady=true jfrog/distribution
         ```
      6. Restore access to new Distribution
      7. Run `helm delete <OLD_RELEASE_NAME>` which will remove remove old Distribution deployment and Helm release.
    * distribution should now be ready to get back to normal operation
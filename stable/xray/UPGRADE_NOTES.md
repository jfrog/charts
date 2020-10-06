# JFrog Xray Chart Upgrade Notes
This file describes special upgrade notes needed at specific versions

## Upgrade from 1.x/2.x to 3.x and above (Chart Versions)
* JFrog Xray v3.x is only compatible with JFrog Artifactory v7.x To upgrade, you must first install JFrog Artifactory 7.x
* To upgrade from a version prior to 1.x, you first need to upgrade to latest version of 1.x as described in https://github.com/jfrog/charts/blob/master/stable/xray/CHANGELOG.md.
* To upgrade from a version of 2.x, you first need to upgrade to the latest version of 2.x as described in https://github.com/jfrog/charts/blob/pre-unified-platform/stable/xray/CHANGELOG.md.

**DOWNTIME IS REQUIRED FOR AN UPGRADE!**
### For 1.x to 3.x and above
* PostgreSQL sub chart was upgraded to version `8.x.x`. This version is not backward compatible with the old version (`0.9.5`)!
* Note the following **PostgreSQL** Helm chart changes
  * The chart configuration has changed! See [values.yaml](values.yaml) for the new keys used
  * **PostgreSQL** is deployed as a StatefulSet
  * See [PostgreSQL helm chart](https://hub.helm.sh/charts/stable/postgresql) for all available configurations
  * Due to breaking changes in the **PostgreSQL** Helm chart, a migration of the database is needed from the old to the new database
* Follow the upgrade process to proceed with the upgrade

### For 2.x to 3.x and above
* From version 3.x, the MongoDB is not used by Xray. Helm upgrade is not possible as mongodb subchart is not there in xray 3.x charts. The solution is to create a new release of xray 3.x and do the migration steps.
* Follow the upgrade process to proceed with the upgrade

## Upgrade process
  * The recommended migration process has 2 Main steps 1.Existing MongoDB data to Existing Postgresql 2.Full DB export and import of Postgresql
    * Upgrade steps:
      1. Prerequisite step to get details of existing chart\
       a. Block user access to Xray (do not shutdown).\
       b. Obtain the service names (OLD_PG_SERVICE_NAME, OLD_MONGO_SERVICE_NAME) using below command\
          Example: OLD_PG_SERVICE_NAME and OLD_MONGO_SERVICE_NAME values are `<OLD_RELEASE_NAME>-postgresql` and `<OLD_RELEASE_NAME>-mongodb` respectively
          ```bash
          $ kubectl get svc
          NAME                                       TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
          <OLD_RELEASE_NAME>-mongodb                 ClusterIP      10.101.56.69     <none>        27017/TCP                     114m
          <OLD_RELEASE_NAME>-postgresql              ClusterIP      10.101.250.74    <none>        5432/TCP                      114m
          <OLD_RELEASE_NAME>-rabbitmq-ha             ClusterIP      None             <none>        15672/TCP,5672/TCP,4369/TCP   114m
          <OLD_RELEASE_NAME>-rabbitmq-ha-discovery   ClusterIP      None             <none>        15672/TCP,5672/TCP,4369/TCP   114m
          <OLD_RELEASE_NAME>-xray-analysis           ClusterIP      10.104.138.63    <none>        7000/TCP                      114m
          <OLD_RELEASE_NAME>-xray-indexer            ClusterIP      10.106.72.163    <none>        7002/TCP                      114m
          <OLD_RELEASE_NAME>-xray-persist            ClusterIP      10.103.20.33     <none>        7003/TCP                      114m
          <OLD_RELEASE_NAME>-xray-server             LoadBalancer   10.105.121.175   <pending>     80:32326/TCP                  114m
         ```
         c. Keep the previous passwords (OLD_PG_PASSWORD, OLD_MONGO_PASSWORD) or Extract them from the secret of the existing postgresql and mongoDB pods
          Example: 
          ```bash
          OLD_PG_PASSWORD=$(kubectl get secret -n <namespace> <OLD_RELEASE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
          OLD_MONGO_PASSWORD=$(kubectl get secret -n <namespace> <OLD_RELEASE_NAME>-mongodb -o jsonpath="{.data.mongodb-password}" | base64 --decode)
          ```
         d. Stop old Xray pods (scale down replicas to 0). Postgresql and MongoDB pods still exists
          ```bash
          $ kubectl scale statefulsets <REPLACE_OLD_RELEASE_NAME>-rabbitmq-ha <REPLACE_OLD_RELEASE_NAME>-xray-analysis <REPLACE_OLD_RELEASE_NAME>-xray-indexer <REPLACE_OLD_RELEASE_NAME>-xray-persist <REPLACE_OLD_RELEASE_NAME>-xray-server --replicas=0
          ```
      2. To Migrate MongoDB data to Postgres - Run the `helm install` (not upgrade) with the `new version`say `xray-new` with\
          a. All Probes disabled 
          ```bash
          --set router.livenessProbe.enabled=false --set router.readinessProbe.enabled=false --set indexer.livenessProbe.enabled=false --set analysis.livenessProbe.enabled=false --set server.livenessProbe.enabled=false --set persist.livenessProbe.enabled=false --set indexer.readinessProbe.enabled=false --set analysis.readinessProbe.enabled=false --set server.readinessProbe.enabled=false --set persist.readinessProbe.enabled=false
          ```
          b. Pointing to previous PostgreSQL pod (user, password,DATABASE)
           ```bash
           --set postgresql.enabled=false --set database.user=<OLD_PG_USERNAME> --set database.password=<OLD_PG_PASSWORD> --set database.url="postgres://<SERVICE_NAME_POSTGRES>:5432/xraydb?sslmode=disable"
           ```
          c. Pointing to previous MongoDB (user, password,DATABASE) pod
           ```bash
           --set xray.mongoUsername=<OLD_MONGO_USERNAME> --set xray.mongoPassword=<OLD_MONGO_PASSWORD> --set xray.mongoUrl="mongodb://<SERVICE_NAME_MONGODB>:27017/?authSource=xray&authMechanism=SCRAM-SHA-1"
           ```
          d. It will trigger the migration process\
          Example:
            ```yaml
            # Create a customvalues.yaml file
            router: 
              livenessProbe:
                enabled: false
              readinessProbe: 
                enabled: false
            indexer: 
              livenessProbe:
                enabled: false
              readinessProbe: 
                enabled: false
            analysis: 
              livenessProbe:
                enabled: false
              readinessProbe: 
                enabled: false
            server: 
              livenessProbe:
                enabled: false
              readinessProbe: 
                enabled: false  
            persist: 
              livenessProbe:
                enabled: false
              readinessProbe: 
                enabled: false
            postgresql:
              enabled: false
            database: 
              user: <OLD_PG_USERNAME>
              password: <OLD_PG_PASSWORD>
              url: "postgres://<SERVICE_NAME_POSTGRES>:5432/xraydb?sslmode=disable"
            xray: 
              mongoUsername: <OLD_MONGO_USERNAME>
              mongoPassword: <OLD_MONGO_PASSWORD>
              mongoUrl: "mongodb://<SERVICE_NAME_MONGODB>:27017/?authSource=xray&authMechanism=SCRAM-SHA-1"
              masterKey: <PREVIOUS_MASTER_KEY>
              jfrogUrl: <NEW_ARTIFACTORY_URL>
              joinKey: <JOIN_KEY>
            rabbitmq:
              enabled: true
              auth: 
                password: <PASSWORD>
            rabbitmq-ha:
              enabled: false
            ```
            ```bash
            # Apply the values file during install
            helm upgrade --install xray-new center/jfrog/xray -f customvalues.yaml
            ```
      3. Stop new Xray pods (scale down replicas to 0). Both Postgresql pods still exists
            ```yaml
            # Create a customvalues.yaml file
            replicaCount: 0
            postgresql:
              postgresqlPassword: <NEW_PG_PASSWORD>
            rabbitmq:
              enabled: true
              auth:
                password: <PASSWORD>
            rabbitmq-ha:
              enabled: false
            xray: 
              masterKey: <PREVIOUS_MASTER_KEY>
              jfrogUrl: <NEW_ARTIFACTORY_URL>
              joinKey: <JOIN_KEY>
            unifiedUpgradeAllowed: true
            databaseUpgradeReady: true
            ```
            ```bash
            # Apply the values file during install
            helm upgrade --install xray-new center/jfrog/xray -f customvalues.yaml
            ```
      4. To Migrate Postgresql data between old and new pods\
          a. Connect to the new PostgreSQL pod (you can obtain the name by running kubectl get pods)
           ```bash
           $ kubectl exec -it <NAME> bash
           ```
          b. Once logged in, create a dump file from the previous database using pg_dump, connect to previous postgresql chart:\
           ```bash
           $ pg_dump -h <OLD_PG_SERVICE_NAME> -U xray DATABASE_NAME > /tmp/backup.sql
           ```
          c. After you ran above command you should be prompted for a password, this password is the previous chart password (OLD_PG_PASSWORD). This operation could take some time depending on the database size.\
          d. Once you have the backup file, you can restore it with a command like the one below:\
            ```bash
            $ psql -U xray DATABASE_NAME < /tmp/backup.sql
            ```
          e. After run above command you should be prompted for a password, this is current chart password.This operation could  take some time depending on the database size.
      5. Run the Upgrade final time which would start xray.\
         Example :
          ```yaml
          # Create a customvalues.yaml file
          xray: 
            masterKey: <PREVIOUS_MASTER_KEY>
            jfrogUrl: <NEW_ARTIFACTORY_URL>
            joinKey: <JOIN_KEY>
          rabbitmq:
            enabled: true
            auth: 
              password: <PASSWORD>
          rabbitmq-ha:
            enabled: false
          postgresql:
            postgresqlPassword: <NEW_PG_PASSWORD>
          unifiedUpgradeAllowed: true
          databaseUpgradeReady: true
          ```
          ```bash
          # Apply the values file during install
          helm upgrade --install xray-new center/jfrog/xray -f customvalues.yaml
          ```
      6. Restore access to new Xray
      7. Run `helm delete <OLD_RELEASE_NAME>` which will remove remove old Xray deployment and Helm release.
    * Xray should now be ready to get back to normal operation

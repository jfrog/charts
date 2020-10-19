# JFrog Mission-Control Chart Upgrade Notes
This file describes special upgrade notes needed at specific versions

## Upgrade from 1.x/2.x to 3.x and above (Chart Versions)

* To upgrade chart version to 3.x and above, you must be on chart version 1.0.5 or above as described in https://github.com/jfrog/charts/blob/master/stable/mission-control/CHANGELOG.md.
* Data other than your licenses, such as your service information and insight, will not be available after the upgrade.
* JFrog Mission Control v4.x is only compatible with JFrog Artifactory v7.x. To upgrade, you must first install JFrog Artifactory 7.x.
* To know more about upgrading mission control, please refer -> https://www.jfrog.com/confluence/display/JFROG/Upgrading+Mission+Control#UpgradingMissionControl-UpgradingfromVersion3.5.1to4.x

**DOWNTIME IS REQUIRED FOR AN UPGRADE!**

* Data export is done with a migration script jfmcDataExport.sh (available under files directory in mission-control chart).

* Upgrade steps:
1. Stop old mission-control pod (scale down replicas to 0). Postgresql still exists
    ```bash
    $ kubectl scale statefulsets <OLD_RELEASE_NAME>-mission-control --replicas=0
    ```
2. Export data from old postgresql instance
    1. Connect to the old PostgreSQL pod (you can obtain the name by running kubectl get pods)
        ```bash
        $ kubectl exec -it <OLD_RELEASE_NAME>-postgresql bash
        ```
    2. Copy the jfmcDataExport.sh file and run the following commands
        ```bash
        $ kubectl cp ./jfmcDataExport.sh <OLD_RELEASE_NAME>-postgresql:/tmp/jfmcDataExport.sh
        $ chown postgres:postgres /tmp/jfmcDataExport.sh
        $ su postgres -c "PGPASSWORD=password bash /tmp/jfmcDataExport.sh --output=/tmp"
        if you are on 2x charts(operating system user postgres is not there) run ./jfmcDataExport.sh --output=/tmp and provide jfmc user password
        ```
    3. Copy the exported file to your local system.
        ```bash
        $ kubectl cp <OLD_RELEASE_NAME>-postgresql:/tmp/jfmcDataExport.tar.gz ./jfmcDataExport.tar.gz
        ```
3. Install new mission-control(4x) and copy the exported file
    1. Run the `helm install` with the `new version` say `mission-control-new`
    2. Copy the exported tar file to the new mission-control pod
        ```bash
        $ kubectl cp ./jfmcDataExport.tar.gz <NEW_RELEASE_NAME>-mission-control:/opt/jfrog/mc/var/bootstrap/mc/jfmcDataExport.tar.gz -c mission-control
        ```
    3. Restart the mission-control new pod
    4. Validate that the import was successful. The filename should be renamed to jfmcDataExport.tar.gz.done. It will be renamed to jfmcDataExport.tar.gz.failed if the import procedure has failed.
4. Run `helm delete <OLD_RELEASE_NAME>` which will remove remove old Mission-control deployment and Helm release.

# JFrog Platform Chart Upgrade Notes
This file describes special upgrade notes needed at specific versions

## Migrate existing installations of Artifactory (11.x and above chart versions) and Artifactory-ha (4.x and above chart versions) to JFrog platform chart

* To migrate you should be on the latest versions of artifactory charts  as described in [artifactory](https://github.com/jfrog/charts/blob/master/stable/artifactory/CHANGELOG.md) and [artifactory-ha](https://github.com/jfrog/charts/blob/master/stable/artifactory-ha/CHANGELOG.md).
* It is recommended to use an external postgresql for production grade deployments


#### Migration steps when using external postgresql
1. System level Import and Export.(recommended) Please refer [here](https://www.jfrog.com/confluence/display/JFROG/Import+and+Export#ImportandExport-SystemImportandExport).  
    Artifactory can export and import the whole Artifactory server: configuration, security information, stored data and metadata. The format used is identical to the System Backup format. This is useful when manually running backups and for migrating and restoring a complete Artifactory instance (as an alternative to using database level backup and restore).\
    Steps:
    1. From the administration UI, export the backup file to a location on the pod(/opt/jfrog/artifactory/var/backup), for the old release. 
    2. Install the platform chart as a new release and copy the exported file to a location(/opt/jfrog/artifactory/var/backup).
    3. Export the file from the platform chart UI.

2. Linking the old **PVC**.
    Steps differ for artifactory and artifactory-ha charts  
    * **For artifactory chart**
    1.  Link the old **PVC** of artifactory chart to new jfrog platform chart release  
        1.  Enable artifactory subchart in jfrog platform release and do an helm upgrade. Old **PVC** should be provided as existing claim   
            Create custom-values.yaml with the following configuration
            ```yaml
            global:
              initDBCreation: false        
            postgresql:
              enabled: false
            rabbitmq:
              enabled: false
            redis:
              enabled: false
            artifactory:
              enabled: true
              artifactory:
                persistence:
                  enabled: true
                  existingClaim: artifactory-volume-<OLD RELEASE NAME>-artifactory-0
            artifactory-ha:
              enabled: false
            xray:
              enabled: false
            distribution:
              enabled: false
            mission-control:
              enabled: false
            pipelines:
              enabled: false
            ```
            ```bash
            helm upgrade --install jfrog-platform stable/jfrog-platform -f custom-values.yaml
            ```
    2. Verify the upgrade and old helm release can be uninstalled. Make sure the old **PVC** is not removed.  
    
    * **For artifactory-ha chart**
    1.  Reuse the old **PVC** of artifactory chart in new jfrog platform chart release  
        **Note**: artifactory-ha chart does not have the option to provide existing claim name for **PVC**. Instead you will need to create a persistent volume claim by a defined name.
        Please refer for more details [here](https://github.com/jfrog/charts/tree/master/stable/artifactory-ha#existing-volume-claim). 
        1. Uninstall the existing release `helm uninstall <old-release-name>` . This would uninstall everything except the **PVC's**. **PVC's** would exist with names like volume-`<old-release-name>`-artifactory-ha-primary-0 and volume-`<old-release-name>`-artifactory-ha-member-`<ordinal-number>` depending upon the number of node replica sets defined.
        2.  Enable artifactory subchart in jfrog platform release and do an helm upgrade.   
            Create custom-values.yaml with the following configuration
            ```yaml
            global:
              initDBCreation: false        
            postgresql:
              enabled: true
            rabbitmq:
              enabled: false
            redis:
              enabled: false
            artifactory:
              enabled: false
            artifactory-ha:
              enabled: true
            xray:
              enabled: false
            distribution:
              enabled: false
            mission-control:
              enabled: false
            pipelines:
              enabled: false
            ```
            **Important** while installing the frog platform chart make sure to use the `<old-release-name>`. This is to reuse the exisiting **PVC's** of the old release.
            ```bash
            helm upgrade --install <old-release-name> stable/jfrog-platform -f custom-values.yaml
            ```

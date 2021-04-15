# JFrog Xray Chart - Deprecation of rabbitmq-ha chart
This file describes the steps for migrating from rabbitmq-ha to bitnami rabbitmq chart before upgrading to chart version 7.x and above

### Steps (Without migration of existing queues- assuming all queues are empty)
* While running the helm upgrade, make sure you don't have any indexing or watches running.
  1. Upgrade xray with bitnami rabbitmq(disabling rabbitmq-ha)
     ```yaml
     rabbitmq-ha:
       enabled: false
     rabbitmq:
       enabled: true
       auth:
         username: guest
         password: password
     ```

### Steps (With migration - downtime is required)
* This is for cases , where you have unfinished tasks in xray running, but still you need to migrate to bitnami rabbitmq.
  1. Detach (disable) xray in artifactory
  2. Upgrade xray with both rabbitmqs (rabbitmq-ha and bitnami's rabbitmq) and scaling down xray services to 0(replicaCount: 0)
     Note: Both rabbitmqs should be scaled down to one replica. Both rabbitmq should have the `ha-mode: all` set(by default it is already set).
     ```yaml
     xray:
     replicaCount: 0
     rabbitmq-ha:
       enabled: true
       replicaCount: 1
     rabbitmq:
       enabled: true
       replicaCount: 1
       auth:
         username: guest
         password: guest
     ```
  3. Get inside the bitnami rabbitmq pod and run 
    ```bash
    export OLD_RMQ=rabbit@`<RELEASE_NAME>`-rabbitmq-ha-0.`<RELEASE_NAME>`-rabbitmq-ha-discovery.`<NAMESPACE_NAME>`.svc.cluster.local && \
    rabbitmqctl stop_app && \
    rabbitmqctl join_cluster $OLD_RMQ && \
    rabbitmqctl start_app
    ```
    The process of data synchronization between rabbitmq-ha and new bitnami rabbitmq node begins. Verify the synchronization with the queues size and count using the command 
    `rabbitmqctl list_queues`. The synchronization status can also be viewed from the rabbitmq dashboard of the old rabbitmq(rabbitmq-ha)
  4. When all data is synchronized between cluster nodes do an helm upgrade to disable the rabbitmq-ha which would remove the old rabbitmq-ha, also bring up the xray services.
     ```yaml
     xray:
     replicaCount: 1
     rabbitmq-ha:
       enabled: false
     rabbitmq:
       enabled: true
       replicaCount: 1
       auth:
         username: guest
         password: guest
     ```
  5. Then remove the old node from bitnami rabbitmq
     ```bash
     rabbitmqctl forget_cluster_node rabbit@`<RELEASE_NAME>`-rabbitmq-ha-0.`<RELEASE_NAME>`-rabbitmq-ha-discovery.`<NAMESPACE_NAME>`.svc.cluster.local
     ```
  6. Enable xray in the artifactory.

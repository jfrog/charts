


```bash
kubectl -n artifactory create secret generic custom-binarystore --from-file=./binarystore.xml 
```
```
artifactory:
  copyOnEveryStartup:
    - source: /artifactory_bootstrap/binarystore.xml
      target: etc/artifactory
  persistence:
    customBinarystoreXmlSecret: "custom-binarystore"
```
```
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory -f custom-values.yaml
```

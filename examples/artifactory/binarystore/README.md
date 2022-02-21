
# Custom Artifactory binaryStore.xml

You can deploy the binaryStore.xml as a Kubernetes Secret. You will need to prepare a XML file with the binaryStore  written in it. 

1. Create a local copy of the binaryStore template suitable for your environment.

2. Modify the values and rename the file name to binarystore.xml

3. Create the Kubernetes secret (The local XML file should be called 'binarystore.xml').

```bash
kubectl -n artifactory create secret generic custom-binarystore --from-file=./binarystore.xml 
```

4. Create a binarystore-values.yaml
```
artifactory:
  copyOnEveryStartup:
    - source: /artifactory_bootstrap/binarystore.xml
      target: etc/artifactory
  persistence:
    customBinarystoreXmlSecret: "custom-binarystore"
```

5. Install with the binarystore-values.yaml.
```
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory -f binarystore-values.yaml
```

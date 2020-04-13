#/bin/bash

kubectl create ns jamadar
helm upgrade --install jamadar --namespace jamadar jamadar/ -f override-values.yaml

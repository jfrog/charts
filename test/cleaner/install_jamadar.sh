#/bin/bash

kubectl create ns jamadar || true
helm3 upgrade --install jamadar --namespace jamadar jamadar/ -f override-values.yaml

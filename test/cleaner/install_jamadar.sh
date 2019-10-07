#/bin/bash

helm tiller run -- helm upgrade --install jamadar --namespace jamadar jamadar/ -f override-values.yaml

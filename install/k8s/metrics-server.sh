#!/bin/bash

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#kubectl -n kube-system patch deploy metrics-server --type='merge' --patch-file patch-metrics-server.yaml

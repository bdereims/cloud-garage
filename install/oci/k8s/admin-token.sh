#!/bin/bash

kubectl -n kube-system get secret $( kubectl -n kube-system get sa admin-user -o json | jq -r '.secrets | .[] | .name' ) -o json | jq -r '.data.token' | base64 -d

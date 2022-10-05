#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#add cluster admin for IDE/CI/CD

KUBECFGSA=kubeconfig-sa

kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:${KUBECFGSA}
TOKENNAME=`kubectl -n kube-system get serviceaccount/${KUBECFGSA} -o jsonpath='{.secrets[0].name}'`
TOKEN=`kubectl -n kube-system get secret $TOKENNAME -o jsonpath='{.data.token}'| base64 --decode`
kubectl config set-credentials ${KUBECFGSA} --token=$TOKEN

kubectl config set-context --current --user=${KUBECFGSA}

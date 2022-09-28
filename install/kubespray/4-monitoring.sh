#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#install prometheus/grafana 

cd
git clone https://github.com/coreos/kube-prometheus
cd  kube-prometheus
kubectl create -f manifests/setup
kubectl create -f manifests/

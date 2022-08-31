#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#delete all kube nodes

. ./env

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' | sed -e "s/\"//g" )

NODES=$( oci compute instance list -c ${COMP_ID} | jq '.data | .[] | ."display-name" | select(contains("worker"))' | sed -e "s/\"//g" )
NODES="${NODES} $( oci compute instance list -c ${COMP_ID} | jq '.data | .[] | ."display-name" | select(contains("master"))' | sed -e "s/\"//g" )"
ALL_NODES=(${NODES})

for NODE in "${ALL_NODES[@]}"
do
	ID=$( oci compute instance list -c ${COMP_ID} | jq '.data | .[] | select(."display-name" == "'${NODE}'") | .id' | sed -e "s/\"//g" )
	echo "${NODE}: ${ID}"
	oci compute instance terminate --instance-id ${ID} --force
done


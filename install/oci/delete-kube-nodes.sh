#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#delete all kube nodes

. ./env

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq -r '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' )

NODES=$( oci compute instance list -c ${COMP_ID} | jq -r '.data | .[] | select(."lifecycle-state" == "RUNNING") | ."display-name" | select(contains("'${NODE_NAME}'"))' )
ALL_NODES=(${NODES})

for NODE in "${ALL_NODES[@]}"
do
	ID=$( oci compute instance list -c ${COMP_ID} | jq -r '.data | .[] | select(."lifecycle-state" == "RUNNING") | select(."display-name" == "'${NODE}'") | .id' )
	echo "${NODE}: ${ID}"
	oci compute instance terminate --instance-id ${ID} --force
done


#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#delete compartment, $1 as compartment display name

. ./env

COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq -r '.["data"] | .[] | select(."name" == "'${1}'") | .id' )
[ "${COMP_ID}" == "" ] && echo "Not possible!" && exit 1

oci iam compartment list --compartment-id-in-subtree true --all | jq '.["data"] | .[] | select(."id" == "'${COMP_ID}'")'

echo "---"
echo "Compartment ID: ${COMP_ID}, hit enter to delete or ctrl-c to abort:" 
read answer

oci iam compartment delete --compartment-id ${COMP_ID} --force

#!/bin/bash 
#bdereims@gmail.com | cloud-garage project
#create and configute vcn

. ./env

# create dedicated compartment
oci iam compartment create -c ${COMP_ID_ROOT} --name ${COMP_NAME} --description "automaticaly created compartment" --wait-for-state "ACTIVE"
COMP_ID=$( oci iam compartment list --compartment-id-in-subtree true --all | jq '.["data"] | .[] | select(."name" == "'${COMP_NAME}'") | .id' | sed -e "s/\"//g" )

# create vcn
oci network vcn create --compartment-id ${COMP_ID} --display-name "${VCN_NAME}" --dns-label ${VCN_NAME} --cidr-block "${VCN_CIDR}" --wait-for-state "AVAILABLE"
VCN_ID=$( oci network vcn list -c ${COMP_ID} | jq '.["data"] | .[] | select(."display-name" == "'${VCN_NAME}'") | .id' | sed -e "s/\"//g" ) 

# create public and private subnet
oci network subnet create -c ${COMP_ID} --vcn-id ${VCN_ID} --display-name "${SNET_PUBLIC_NAME}" --dns-label ${SNET_PUBLIC_NAME} --cidr-block "${SNET_PUBLIC_CIDR}"
SBNT_PUBLIC_ID=$(oci network subnet list -c ${COMP_ID} --display-name public | jq '.[] | .[] | .id' | sed -e "s/\"//g" )

oci network subnet create -c ${COMP_ID} --vcn-id ${VCN_ID} --display-name "${SNET_PRIVATE_NAME}" --dns-label ${SNET_PRIVATE_NAME} --cidr-block "${SNET_PRIVATE_CIDR}" --prohibit-public-ip-on-vnic true 

# internet connectivity
oci network internet-gateway create --compartment-id ${COMP_ID}  --vcn-id ${VCN_ID} --display-name "Internet GW for ${VCN_NAME}" --is-enabled true
IGW_ID=$( oci network internet-gateway list -c ${COMP_ID} | jq '.["data"] | .[] | select(."display-name" == "Internet GW for '${VCN_NAME}'") | .id' | sed -e "s/\"//g" )

RTBL_ID=$( oci network route-table list -c ${COMP_ID} | jq '.["data"] | .[] | select(."display-name" == "Default Route Table for '${VCN_NAME}'") | .id' | sed -e "s/\"//g" )
oci network route-table update --rt-id ${RTBL_ID} --route-rules '[{"cidrBlock":"0.0.0.0/0","networkEntityId":"'${IGW_ID}'"}]' --force

# security list
SECL_ID=$( oci network security-list list -c ${COMP_ID} | jq '.["data"] | .[] | select(."display-name" == "Default Security List for '${VCN_NAME}'") | .id' | sed -e "s/\"//g" )
oci network security-list update --security-list-id ${SECL_ID} --ingress-security-rules '[{"source": "0.0.0.0/0", "protocol": "17", "isStateless": false, "udpOptions": {"destinationPortRange": {"max": 8172, "min": 8172}}}, {"source": "0.0.0.0/0", "protocol": "6", "isStateless": false, "tcpOptions": {"destinationPortRange": {"max": 22, "min": 22}}}]' --force

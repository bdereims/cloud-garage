#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#generate certs

DOMAIN="cloud-garage.net"
SUBJET="/C=FR/ST=Paris/L=Paris/O=cloud-garage/OU=services/CN=*.${DOMAIN}"
CERTDIR="certs"

if [ -f ${CERTDIR}/ca-key.pem ]; then
	echo "ca already generated."
else
	mkdir -p ${CERTDIR}
	openssl genrsa -out ${CERTDIR}/ca-key.pem 2048
	openssl req -x509 -new -nodes -key ${CERTDIR}/ca-key.pem -days 10000 -out ${CERTDIR}/ca.pem -subj "/CN=etcd-ca"
fi

export NODE_IP="${1}"
export NODE_HOSTNAME="${2}"

./evaluate.sh ./openssl.conf > ${CERTDIR}/openssl.conf
export CONFIG="${PWD}/${CERTDIR}/openssl.conf"

CN="/CN=${1}"
openssl genrsa -out ${CERTDIR}/${NODE_HOSTNAME}-key.pem 2048
openssl req -new -key ${CERTDIR}/${NODE_HOSTNAME}-key.pem -out ${CERTDIR}/${NODE_HOSTNAME}.csr -subj ${CN} -config ${CONFIG}
openssl x509 -req -in ${CERTDIR}/${NODE_HOSTNAME}.csr -CA ${CERTDIR}/ca.pem -CAkey ${CERTDIR}/ca-key.pem -CAcreateserial -out ${CERTDIR}/${NODE_HOSTNAME}.pem -days 3650 -extensions ssl_client -extfile ${CONFIG}

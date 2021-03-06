#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#generate cert

DOMAIN="cloud-garage.net"
SUBJET="/C=FR/ST=Paris/L=Paris/O=cloud-garage/OU=services/CN=*.${DOMAIN}"

echo "=== Generate cert"

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
-subj "${SUBJET}" \
-key ca.key \
-out ca.crt

openssl genrsa -out ${DOMAIN}.key 4096

openssl req -sha512 -new \
-subj "${SUBJET}" \
-key ${DOMAIN}.key \
-out ${DOMAIN}.csr

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=*.${DOMAIN}
EOF

openssl x509 -req -sha512 -days 3650 \
-extfile v3.ext \
-CA ca.crt -CAkey ca.key -CAcreateserial \
-in ${DOMAIN}.csr \
-out ${DOMAIN}.crt

openssl x509 -inform PEM -in ${DOMAIN}.crt -out ${DOMAIN}.cert

rm v3.ext

DEST=/etc/certs
mkdir -p ${DEST} 
mv ca.* ${DEST}
mv ${DOMAIN}.* ${DEST}

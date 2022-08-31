#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#install and configure oracle cli

# generate key and fingerprint - optionnal = 'oci setup config' will do the same thing
#mkdir ~/.oci
#openssl genrsa -out ~/.oci/oci_api_key.pem 2048
#chmod go-rwx ~/.oci/oci_api_key.pem 
#openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

# key's fingerprint
#openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c >  ~/.oci/fingerprint

# install oci cli
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"


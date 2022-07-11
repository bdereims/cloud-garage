#!/bin/bash
#bdereims@gmail.com | cloud-garage project
#replace variable in file

DOMAINNAME=$(domainname)

set -e
eval "cat <<EOF
$(<$1)
EOF
" 

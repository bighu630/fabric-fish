#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}


function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=./crypto-config/peerOrganizations/Peer_fish.com/tlsca/tlsca.Peer_fish.com-cert.pem
CAPEM=./crypto-config/peerOrganizations/Peer_fish.com/ca/ca.Peer_fish.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./crypto-config/peerOrganizations/Peer_fish.com/connection-fish.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./crypto-config/peerOrganizations/Peer_fish.com/connection-fish.yaml

ORG=2
P0PORT=9051
CAPORT=8054
PEERPEM=./crypto-config/peerOrganizations/Rest.com/tlsca/tlsca.Rest.com-cert.pem
CAPEM=./crypto-config/peerOrganizations/Rest.com/ca/ca.Rest.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./crypto-config/peerOrganizations/Rest.com/connection-rest.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > ./crypto-config/peerOrganizations/Rest.com/connection-rest.yaml

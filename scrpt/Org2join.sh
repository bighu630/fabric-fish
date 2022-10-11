#!/bin/bash

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/users/Admin\@Rest.com/msp

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0.rest.com:9051

peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/scrpt/fish-channel.block

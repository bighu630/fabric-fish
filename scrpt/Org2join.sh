export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/users/Admin\@Rest.com/msp

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0.rest.com:9051

peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/scrpt/fish-channel.block

peer channel update -o orderer.fish.com:7050 -c fish-channel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel/fishArchor.tx --tls /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

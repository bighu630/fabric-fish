export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/users/Admin\@Peer_fish.com/msp

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0.Peer_fish.com:7051

peer channel create -o orderer.fish.com:7050 -c fish-channel --ordererTLSHostnameOverride orderer.fish.com -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel/channel.tx --timeout "30s" --tls /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

sleep 10

peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/scrpt/fish-channel.block

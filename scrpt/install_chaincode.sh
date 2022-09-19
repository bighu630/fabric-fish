#为fish安装链码
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/users/Admin\@Peer_fish.com/msp

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0.Peer_fish.com:7051

#打包链码
peer lifecycle chaincode package test.tar.gz \
  --path ../chaincode \
  --lang golang --label test

sleep 5

#在当前节点安装链码
peer lifecycle chaincode install test.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

# 查询是否安装成功
#peer lifecycle chaincode queryinstalled --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

#设置orderer的tls证书位置，因为要与orderer进行通信
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

#提交审批
peer lifecycle chaincode approveformyorg  -o orderer.fish.com:7050 \
  --tls /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem --cafile $ORDERER_CA --channelID fish-channel --name test \
  --version 1.0 --init-required \
  --package-id test:8f21a1652397c6d16fb049a9b934e7d07fedd935783d06f970310ee879a2f9fa \
  --sequence 1 --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

# 为rest安装链码
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/users/Admin\@Rest.com/msp

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0.rest.com:9051

peer lifecycle chaincode install pukcc.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE


peer lifecycle chaincode approveformyorg  -o orderer.fish.com:7050 \
  --tls /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem --cafile $ORDERER_CA --channelID fish-channel --name test \
  --version 1.0 --init-required \
  --package-id test:2e6ff79b31ac106dfc62a189d76a8d79e9b9f68314f7fdbf9ca1575d4a7af9db \
  --sequence 1 --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

peer lifecycle chaincode commit -o orderer.fish.com:7050 \
  --channelID fish-channel --name test --version 1.0 --sequence 1 --init-required \
  --tls --cafile $ORDERER_CA --peerAddresses peer0.Peer_fish.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt \
  --peerAddresses peer0.Rest.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE \
  --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

peer lifecycle chaincode checkcommitreadiness --channelID fish-channel --name test --version 1.0 --init-required --sequence 1 \
  --tls --cafile $ORDERER_CA --peerAddresses peer0.Peer_fish.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt \
  --peerAddresses peer0.Rest.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE \
  --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"


peer chaincode invoke -o orderer.fish.com:7050 -C fish-channel --name test \
  --peerAddresses peer0.Peer_fish.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt \
  --peerAddresses peer0.Rest.com:9051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/ca.crt \
  --tls /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem \
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem \
  -I -c '{"Args":["init","00001","鳟鱼","良好","8kg","良好"]}'



# peer chaincode invoke -o orderer.fish.com:7050 -C fish-channel -n test3 --peerAddresses peer0.Peer_fish.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt --peerAddresses peer0.Rest.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/ca.crt -c '{"Args":["AddPubKey","00001",$pubkey]}' --tls /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/tls-localhost-9054-ca-orderer.pem --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

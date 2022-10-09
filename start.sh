#!/bin/bash
#删除docker文件
cd ./compose_conf || exit
docker-compose -f compose-couch.yaml -f compose_fish_peer.yaml -f compose_rest_peer.yaml -f compose_fish_orderer.yaml -f compose_fish_cli.yaml down
docker volume prune

cd .. || exit

#删除所有遗留文件
sudo rm -r ./ca_conf/fish/*
sudo rm -r ./ca_conf/rest/*
sudo rm -r ./ca_conf/ordererca/*
rm -r ./org_crypto_conf/organizations/*
rm ./configtx/channel-artifacts/*

#创建组织文件结构
cd ./org_crypto_conf || exit
cryptogen generate --config=./crypto-config.yaml --output="organizations"

#开启ca
cd ../compose_conf || exit
docker-compose -f compose_ca.yaml up -d
sleep 10

#向ca申请身份
cd ../ca_conf || exit
bash ./enroll.sh

#配置创世快
cd ../configtx || exit
configtxgen -profile TwoOrgsChannel -channelID fish-channel -outputCreateChannelTx ./channel-artifacts/channel.tx
configtxgen -profile TwoOrgsOrdererGenesis -channelID fabric-channel -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile TwoOrgsChannel -channelID fish-channel -asOrg Org1MSP -outputAnchorPeersUpdate ./channel-artifacts/fishArchor.tx

#启动
cd ../compose_conf || exit
docker-compose -f compose-couch.yaml -f compose_fish_peer.yaml -f compose_rest_peer.yaml -f compose_fish_orderer.yaml -f compose_fish_cli.yaml up -d
sleep 20
docker ps

#加入通道
docker exec -it clifish bash /opt/gopath/src/github.com/hyperledger/fabric/peer/scrpt/Org1join.sh
docker exec -it clifish bash /opt/gopath/src/github.com/hyperledger/fabric/peer/scrpt/Org2join.sh

package app

import (
	"log"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

var sdk *fabsdk.FabricSDK

// creatsdk 建一个全局sdk
func creatsdk() {
	var err error
	sdk, err = fabsdk.New(config.FromFile("../config/org1sdk-config.yaml"))
	if err != nil {
		log.Panicf("failed to creat fabricsdk :%s", err)

	}
}

// creatRC 创建一个用于管理的管理员账号
func creatRC() *resmgmt.Client {
	rcp := sdk.Context(fabsdk.WithUser("Admin"), fabsdk.WithOrg("Org1"))
	rc, err := resmgmt.New(rcp)
	if err != nil {
		log.Fatalf("failed to creat rc : %s", err)
	}
	return rc

}

// creatCCP 创建一个用户调用链码的账号
func creatCCP(ChannelID string) *channel.Client {
	ccp := sdk.ChannelContext(ChannelID, fabsdk.WithUser("User1"))
	cc, err := channel.New(ccp)
	if err != nil {
		log.Panicf("failed to create client: %s", err)
	}
	return cc
}

func installCC(ccPath string) {

}

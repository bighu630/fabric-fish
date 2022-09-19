package main

import (
	"fmt"

	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

func main() {
	sdk, err := fabsdk.New(configOpt, sdkOpts...)
	fmt.Println("vim-go")
}

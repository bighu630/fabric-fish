package main

import (
	//  "strconv"
	//  "strings"

	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type FishChainCode struct {
}

type FishInfo struct {
	FishID      string `json:"FishID"`      //鱼的ID
	FishName    string `json:"FishName"`    //鱼的名称(种类)
	WaterInfo   string `json:"WaterInfo"`   //水质
	FishWeight  string `json:"FishWeight"`  //鱼的重量
	FishQuality string `json:"FishQuality"` //鱼的品质
}

func (f *FishChainCode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func (f *FishChainCode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fn, args := stub.GetFunctionAndParameters()
	if fn == "funAddAFish" {
		return f.funAddAFish(stub, args)
	} else if fn == "funGetFishInfo" {
		return f.funGetFishInfo(stub, args)
	}
	return shim.Error("Recevied unkown function invocation")
}

func (f *FishChainCode) funAddAFish(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var FishInfos FishInfo
	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments.")
	}
	FishInfos.FishID = args[0]
	if FishInfos.FishID == "" {
		return shim.Error("FishID can not be empty.")
	}
	FishInfos.FishName = args[1]
	FishInfos.WaterInfo = args[2]
	FishInfos.FishWeight = args[3]
	FishInfos.FishQuality = args[4]

	FishInfosJSONasBytes, err := json.Marshal(FishInfos)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(FishInfos.FishID, FishInfosJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (f *FishChainCode) funGetFishInfo(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments.")
	}
	FishID := args[0]
	resultsIterator, err := stub.GetHistoryForKey(FishID)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	var fishinfo FishInfo

	for resultsIterator.HasNext() {
		//读取数据
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		//解析数据为结构体
		json.Unmarshal(response.Value, &fishinfo)
	}
	//解析数据为json
	jsonsAsBytes, err := json.Marshal(fishinfo)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(jsonsAsBytes)
}

func main() {
	err := shim.Start(new(FishChainCode))
	if err != nil {
		fmt.Printf("Error starting Food chaincode: %s ", err)
	}
}

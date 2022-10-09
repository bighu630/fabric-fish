package main

import (
	//  "strconv"
	//  "strings"

	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

const waterPrefix = "water"
const fishPrefix = "fish"

type FishChainCode struct {
}

type FishInfo struct {
	FishID      string `json:"FishID"`      //鱼的ID
	FishName    string `json:"FishName"`    //鱼的名称(种类)
	WaterInfo   string `json:"WaterInfo"`   //水质
	FishWeight  string `json:"FishWeight"`  //鱼的重量
	FishQuality string `json:"FishQuality"` //鱼的品质
}

type WaterInfo struct {
	FishID       string `json:"FishID"`       //鱼的ID
	Temperature  string `json:"Temperature"`  //温度
	Chroma       string `json:"Chroma"`       //色度
	Turbidity    string `json:"Turbidity"`    //浑浊度
	Conductivity string `json:"Conductivity"` //导电率
	TimefoAdd    string `json:"Time"`         //添加时间
}

//链码初始化
func (f *FishChainCode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

//Invoke 方法，相当于是路由
func (f *FishChainCode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fn, args := stub.GetFunctionAndParameters()
	if fn == "funAddAFish" {
		return f.funcAddAFish(stub, args)
	} else if fn == "funGetFishInfo" {
		return f.funcGetFishInfo(stub, args)
	}
	return shim.Error("Recevied unkown function invocation")
}

// funAddAFish 添加一条“鱼”的信息到区块链上
func (f *FishChainCode) funcAddAFish(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var FishInfos FishInfo

	//输入判断
	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments.")
	}

	//输入解析
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

	//构造复合键
	fishKey, err := stub.CreateCompositeKey(fishPrefix, []string{FishInfos.FishID})
	if err != nil {
		return shim.Error(err.Error())
	}

	//提交信息
	err = stub.PutState(fishKey, FishInfosJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

// funcGetFishInfo 读取一条鱼的信息
func (f *FishChainCode) funcGetFishInfo(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	//判断输入是否合法
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments.")
	}

	//构造查询复合键
	FishID := args[0]
	fishKey, err := stub.CreateCompositeKey(fishPrefix, []string{FishID})
	if err != nil {
		return shim.Error(err.Error())
	}

	//查询
	results, err := stub.GetState(fishKey)
	if err != nil {
		return shim.Error(err.Error())
	}

	var fishinfo FishInfo

	//读取数据
	if err != nil {
		return shim.Error(err.Error())
	}
	//解析数据为结构体
	json.Unmarshal(results, &fishinfo)
	//解析数据为json
	jsonsAsBytes, err := json.Marshal(fishinfo)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(jsonsAsBytes)
}

func (f *FishChainCode) funcAddWaterInfo(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var WaterInfos WaterInfo

	//输入判断
	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments.")
	}

	//输入解析
	WaterInfos.FishID = args[0]
	if WaterInfos.FishID == "" {
		return shim.Error("FishID can not be empty.")
	}
	WaterInfos.Temperature = args[1]
	WaterInfos.Chroma = args[2]
	WaterInfos.Turbidity = args[3]
	WaterInfos.Conductivity = args[4]
	WaterInfos.TimefoAdd = time.Now().Format()

	waterInfoJSONasBytes, err := json.Marshal(WaterInfos)
	if err != nil {
		return shim.Error(err.Error())
	}

	//构造复合键
	waterKey, err := stub.CreateCompositeKey(waterPrefix, []string{WaterInfos.FishID})
	if err != nil {
		return shim.Error(err.Error())
	}

	//提交信息
	err = stub.PutState(waterKey, waterInfoJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (f *FishChainCode) funcGetWaterInfo(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//判断输入是否合法
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments.")
	}

	//构造查询复合键
	FishID := args[0]
	waterKey, err := stub.CreateCompositeKey(waterPrefix, []string{FishID})
	if err != nil {
		return shim.Error(err.Error())
	}

	//查询
	results, err := stub.GetState(waterKey)
	if err != nil {
		return shim.Error(err.Error())
	}

	var fishinfo FishInfo

	//读取数据
	if err != nil {
		return shim.Error(err.Error())
	}
	//解析数据为结构体
	json.Unmarshal(results, &fishinfo)
	//解析数据为json
	jsonsAsBytes, err := json.Marshal(fishinfo)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(jsonsAsBytes)

}

func main() {
	//开启链码
	err := shim.Start(new(FishChainCode))
	if err != nil {
		fmt.Printf("Error starting Food chaincode: %s ", err)
	}
}

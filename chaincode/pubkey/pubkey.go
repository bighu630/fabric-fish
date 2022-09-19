//The chaincode is used to save user's publicKey
//but there is no struct for am key
//so if you want to get this key,you'd better not
//creat am struct to get it
package main

import (
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/peer"
)

type PubKeyBook struct {
}

//Init 初始化函数
func (s *PubKeyBook) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (s *PubKeyBook) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	fn, args := stub.GetFunctionAndParameters()
	if fn == "AddPubKey" {
		return s.AddPubKey(stub, args)
	}
	if fn == "QueryKey" {
		return s.QueryKey(stub, args[0])
	}
	if fn == "ReceveUserKeuy" {
		return s.ReviceUserKey(stub, args)
	}
	if fn == "DelUserKey" {
		return s.DelUserKey(stub, args[0])

	}

	return shim.Error("Recevied unkown function invocation")
}

// AddPubKey you can use this function to add am user and his publicKey
//the data well be used to prove the user's identify
func (s *PubKeyBook) AddPubKey(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	//chkey if the userID is exist
	user, err := stub.GetState(args[0])
	if err != nil {

		return shim.Error("Failed to read from world state" + err.Error())
	}

	if user != nil {
		return shim.Error("The userID has been exist")
	}
	publicKeyBytes, _ := pem.Decode([]byte(args[1]))
	if publicKeyBytes == nil {
		return shim.Error("unable get the pubKey" + args[1])
	}
	derStream := publicKeyBytes.Bytes
	publicKey, err := x509.ParsePKIXPublicKey(derStream)
	if err != nil {
		return shim.Error("get errror pubkey")
	}

	// if the userID not exist ,creart it
	PubKeyAsBytes, _ := json.Marshal(publicKey)

	response := stub.PutState(args[0], PubKeyAsBytes)
	if response != nil {
		return shim.Error("Unable to add key")
	}
	return shim.Success(nil)
}

//QueryKey Query the user's pubKey by userID
func (s *PubKeyBook) QueryKey(stub shim.ChaincodeStubInterface, userID string) peer.Response {
	// try to get information by userID
	userAsbytes, err := stub.GetState(userID)
	if err != nil {
		return shim.Error(err.Error())
	}
	if userAsbytes == nil {
		return shim.Error(err.Error())
	}
	return shim.Success(userAsbytes)
}

//ReviceUserKey
func (s *PubKeyBook) ReviceUserKey(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	// try to get the userID information
	user := s.QueryKey(stub, args[0])
	//如果返回值不是200 则表示没有这个状态
	if user.Status != 200 {
		return shim.Error(args[0] + "does not exist")
	}
	//decode string to key project
	publicKeyBytes, _ := pem.Decode([]byte(args[1]))
	if publicKeyBytes == nil {
		return shim.Error("The new public key is incorrect")
	}
	derStream := publicKeyBytes.Bytes
	publicKey, err := x509.ParsePKIXPublicKey(derStream)
	if err != nil {
		return shim.Error("The new public key is incorrect")
	}
	userNewPublicKey, _ := json.Marshal(publicKey)

	//updata to the databases
	err = stub.PutState(args[0], userNewPublicKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

//DelUserKey delit an userKey
func (s *PubKeyBook) DelUserKey(stub shim.ChaincodeStubInterface, userID string) peer.Response {
	// try to get the userID information
	user := s.QueryKey(stub, userID)
	if user.Status != 200 {
		return shim.Error(userID + "does not exist")
	}
	err := stub.DelState(userID)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func main() {
	err := shim.Start(new(PubKeyBook))
	if err != nil {
		fmt.Printf("Error starting PubKey chaincode: %s ", err)
	}

}

package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	fmt.Println("chaincode")
}

type MusicCopyright struct {
	contractapi.Contract
}

//对于某个作品的数据结构
//type DigitalAsset struct {
//	DigitalHash        string    `json:"digitalasset"` //数字资产特征值
//	DataUrl            string    `json:"dataurl"`      //数字资产存放地址
//	TimeOffset         time.Time `json:"timeoffset"`   //版权注册时间
//	Validity           int       `json:"validity"`     //有效时间，天
//	UserName           string    `json:"username"`     //用户名
//	UserID             string    `json:"userid"`       //用户ID
//	Permission         bool      `json:"permission"`   //权限，F表示使用权，T表示所有权
//	UsePermissionPrice float64   `json:"useprice"`     //使用权售价
//}

//只有某些组织能查看的私有数据(这些数据不会被其他组织看到)
//type PrivatePrice struct {
//	DigitalHash string  `json:"digitalasset"`
//	Sellable    bool    `json:"sellable"` //是否可出售
//	OwnPrice    float64 `json:"ownprice"` //售价
//}

func (s *MusicCopyright) AddArtwork(ctx contractapi.TransactionContextInterface, args []string) error {

	//需要保护的
	type privdata struct {
		Permission         bool    `json:"permission"` //权限，F表示使用权，T表示所有权
		UsePermissionPrice float64 `json:"useprice"`   //使用权售价
		Sellable           bool    `json:"sellable"`   //是否可出售
		OwnPrice           float64 `json:"ownprice"`   //售价
	}

	//接受数据的结构体
	type artwork struct {
		DigitalHash string            `json:"digitalasset"` //数字资产特征值
		DataUrl     string            `json:"dataurl"`      //数字资产存放地址
		TimeOffset  string            `json:"timeoffset"`   //版权注册时间
		Validity    int               `json:"validity"`     //有效时间，天
		UserID      string            `json:"userid"`       //用户ID
		privdata    []byte            `json:"privdata"`     //被加密的被保护数据
		privKeyList map[string][]byte `json:"keyMap"`       //访问控制列表（userID-ENC(key,userPubkey)）
	}

	var err error
	var artworkInput artwork
	//err := json.Unmarshal(transactArtworkJSON, &artworkInput)
	//判断输入是否合法
	if len(args) < 10 {
		return fmt.Errorf("You mast push 10+ values")
	}
	if len(args[0]) == 0 {
		return fmt.Errorf("DigitalHash must be a no-enpty string")
	}
	if len(args[1]) == 0 {
		return fmt.Errorf("DataUrl must be a no-enpty string")
	}
	if len(args[2]) == 0 {
		return fmt.Errorf("TimeOffset must be a no-enpty string")
	}
	if len(args[3]) == 0 {
		return fmt.Errorf("Validity must be a no-enpty string")
	}
	if len(args[4]) == 0 {
		return fmt.Errorf("UserID must be a no-enpty string")
	}
	if len(args[5]) == 0 {
		return fmt.Errorf("Permission must be a bool")
	}
	if len(args[6]) == 0 {
		return fmt.Errorf("UserPermissionPrice must be a int")
	}
	if len(args[7]) == 0 {
		return fmt.Errorf("Sellable must be a int")
	}
	if len(args[8]) == 0 {
		return fmt.Errorf("OwnPrice must be a int")

	}

	//将输入整合为对应结构
	artworkInput.DigitalHash = args[0]
	artworkInput.DataUrl = args[1]
	artworkInput.TimeOffset = args[2]
	artworkInput.Validity, err = strconv.Atoi(args[3])
	if err != nil {
		return fmt.Errorf("UserPermissionPrice must be a int")
	}
	artworkInput.UserID = args[4]

	//构建私有数据
	var priv privdata
	priv.Permission = strconv.CanBackquote(args[5])
	priv.UsePermissionPrice, err = strconv.ParseFloat(args[6], 64)
	if err != nil {
		return fmt.Errorf("UserPermissionPrice must be a float64")
	}
	priv.Sellable = strconv.CanBackquote(args[7])
	priv.OwnPrice, err = strconv.ParseFloat(args[8], 64)
	if err != nil {
		return fmt.Errorf("UserPermissionPrice must be a float64")
	}
	privData, err := json.Marshal(priv)
	if err != nil {
		return fmt.Errorf("Marshal priv_data error! ")
	}

	//构建aes加密密钥
	AESkey := make([]byte, 64)

	_, err = rand.Read(AESkey)
	if err != nil {
		return err
	}
	//使用aes加密私有数据
	artworkInput.privdata, err = AesEncrypt(privData, AESkey)

	//获取侧链的非对称钥的公钥
	response := ctx.GetStub().InvokeChaincode("pubkey", toChaincodeArgs2("QueryKey", args[4]), "fabric-fish")
	if response.Status != 200 {
		return fmt.Errorf("get user publickey error")
	}
	artworkInput.privKeyList[args[4]] = response.Payload
	//获取被授权方的公钥
	response = ctx.GetStub().InvokeChaincode("pubkey", toChaincodeArgs2("QueryKey", args[9]), "fabric-fish")
	if response.Status != 200 {
		return fmt.Errorf("get user publickey error")
	}
	return nil
}

//PKCS5Padding 补位
func PKCS5Padding(ciphertext []byte, blockSize int) []byte {
	padding := blockSize - len(ciphertext)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(ciphertext, padtext...)
}

//PKCS5UnPadding 删除补位
func PKCS5UnPadding(origData []byte) []byte {
	length := len(origData)
	unpadding := int(origData[length-1])
	return origData[:(length - unpadding)]
}

//AesEncrypt 加密函数
func AesEncrypt(origData, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	blockSize := block.BlockSize()
	origData = PKCS5Padding(origData, blockSize)
	blockMode := cipher.NewCBCEncrypter(block, key[:blockSize])
	crypted := make([]byte, len(origData))
	blockMode.CryptBlocks(crypted, origData)
	return crypted, nil
}

//AesDecrypt 解密函数
func AesDecrypt(crypted, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	blockSize := block.BlockSize()
	blockMode := cipher.NewCBCDecrypter(block, key[:blockSize])
	origData := make([]byte, len(crypted))
	blockMode.CryptBlocks(origData, crypted)
	origData = PKCS5UnPadding(origData)
	return origData, nil
}

//toChaincodeArgs2 将多个参数整合为 [][]byte
func toChaincodeArgs2(args ...string) [][]byte {
	bargs := make([][]byte, len(args))
	for i, arg := range args {
		bargs[i] = []byte(arg)
	}
	return bargs
}

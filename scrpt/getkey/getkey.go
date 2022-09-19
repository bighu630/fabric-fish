package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io/ioutil"
	"os"
)

var (
	data string = "test"
)

func main() {
	err := funcGetKeyFromFile()
	if err != nil {
		panic(err)
	}
}

func funcGetKeyFromFile() error {
	//读取私钥
	KeyFile, err := os.Open("../private.pem")
	if err != nil {
		return err
	}
	defer KeyFile.Close()
	privateKeyFile, err := ioutil.ReadAll(KeyFile)
	if err != nil {
		return err
	}
	privateKeyBytes, _ := pem.Decode(privateKeyFile)
	if privateKeyBytes == nil {
		return nil
	}
	derStream := privateKeyBytes.Bytes
	privateKey, err := x509.ParsePKCS1PrivateKey(derStream)
	if err != nil {
		return err
	}

	//读取公钥
	KeyFile, err = os.Open("../public.pem")
	if err != nil {
		return err
	}
	defer KeyFile.Close()
	publicKeyFile, err := ioutil.ReadAll(KeyFile)
	keydata := string(publicKeyFile)
	fmt.Println(keydata)
	if err != nil {
		return err
	}
	publicKeyBytes, _ := pem.Decode([]byte(keydata))
	if privateKeyBytes == nil {
		return nil
	}
	derPkix := publicKeyBytes.Bytes
	publicKeyInter, err := x509.ParsePKIXPublicKey(derPkix)
	if err != nil {
		return err
	}

	publicKey := publicKeyInter.(*rsa.PublicKey)
	cipherText, err := rsa.EncryptPKCS1v15(rand.Reader, publicKey, []byte(data))
	if err != nil {
		return err
	}
	fmt.Println(string(cipherText))
	planText, err := rsa.DecryptPKCS1v15(rand.Reader, privateKey, cipherText)
	if err != nil {
		return err
	}
	fmt.Println(string(planText))

	return nil
}

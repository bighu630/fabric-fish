# fabric-fish

#### 网络结构

![image-20220909203114581](https://raw.githubusercontent.com/bighu630/img/main/fabric-fish%E7%BD%91%E7%BB%9C%E7%BB%93%E6%9E%84.png)

#### 启动网络

###### 1）启动之前需修改 ca_conf/enroll.sh 中的文件位置

```sh
#需要修改为对应的目录
fabricRest=/home/bighu/文档/区块链/fabric-Restaurant
```

###### 2）运行start.sh

这将删除ca_conf下的ca文件，org_crypto_conf 下的org文件，然后重新org，然后启动网络中的各个节点

###### 3）进入容器安装通道传世块，智能合约

```sh
#进入容器
docker exec -it clifish bash
ls
cd scrpt
./Org1join.sh
./Org2join.sh
#参照install_chaincode.sh 中的步骤依次执行，需要修改链码的ID,故不能直接运行install_chaincode.sh 

```




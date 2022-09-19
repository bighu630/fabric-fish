###整个启动过程
```sh
#删除相关文件
sudo rm -r ./ca_conf/fish/*     
sudo rm -r ./ca_conf/rest/*
sudo rm -r ./ca_conf/ordererca/*
rm -r ./org_crypto_conf/organizations/*


#产生相关的密钥文件
cd ./org_crypto_conf
cryptogen generate --config=./crypto-config.yaml  --output="organizations"



#开启CA服务
cd ../compose_conf
docker-compose -f compose_ca.yaml up -d
sleep 3


#向ca注册相关身份
cd ../ca_conf
bash ./enroll.sh


#产生系统通道与应用通道的配置文件
cd ../configtx
configtxgen -profile TwoOrgsChannel -channelID fish-channel -outputCreateChannelTx ./channel-artifacts/channel.tx
configtxgen -profile TwoOrgsOrdererGenesis -channelID fabric-channel -outputBlock ./channel-artifacts/genesis.block


#开启网络
cd ../compose_conf
docker-compose -f compose-couch.yaml -f compose_fish_peer.yaml -f compose_rest_peer.yaml -f compose_fish_orderer.yaml -f compose_fish_cli.yaml up -d
```

####重要文件目录
```sh
.
├── ca\_conf 	ca的配置文件(实际上只需要生成三个ca的空文件夹,ca启动时会自动生成相关的文件,由于启动时不能生成文件夹,所以要自己建立文件夹,具体要看compose文件中ca部分的配置);enroll.sh这个脚本是用来注册身份的
├── chaincode 	链码文件夹于网络搭建无关
├── compose\_conf 	#docker的启动配置
├── configtx 		#核心文件,负责配置通道和网络
├── org\_crypto\_conf 	#主要存放组织的结构
├── scrpt
└── start.sh
```


####核心文件
- org\_crypto\_conf/crypto\_config.yaml #用于生成网络的结构(或者说是网络中的组织结构)
- compose\_conf #是各个节点启动的配置
- config/configtx.yaml #用于生成网络的结构,是大家相互认识的核心

####compose\_conf文件夹说明
```sh
.
├── compose-couch.yaml 		#couch数据库的配置文件
├── compose_ca.yaml 		#ca的配置文件
├── compose_fish_cli.yaml 	#客户端的配置文件
├── compose_fish_orderer.yaml 	#orderer组织的配置文件
├── compose_fish_peer.yaml 	#fish组织的peer配置文件
├── compose_rest_peer.yaml 	#rest组织的peer配置文件
├── composefile 		#本说明文件
└── peercfg 			#启动peer的配置文件,peer的核心配置(但是不建议修改,官方的方案是使用默认文件,需要改的地方在compose文件中指定环境变量,所以这里是在官网上拷贝下来的,实际上没什么要细说的)
   ├── core.yaml
   └── mspreally
      └── keystore
```


####删除文件部分
解释:
- 在ca\_conf这个文件夹下面有ca的相关文件
- 这里的有些文件在注册身份时用的上
- 这些文件不许要手动生成,他会在docker启动时自动生成(详情见compose\_ca.yaml)




####产生相关密钥部分
解释:

cryptogen generate --config=./crypto-config.yaml  --output="organizations"
- cryptogen 是fabric官方提供的一个配置生成工具(直接使用需要下载相关文件并设置环境变量)
- generate 该工具的子命令
- \-\-config= 用来指定配置文件(该配置文件需要自己写,配置方法文件中有)
- \-\-output 指定输出在那个文件夹里面,该文件夹会自动生成

文件结构图如下:

```sh
.
├── ordererOrganizations   #orderer组织的相关文件
│  └── fish.com 	   #组织名称
│     ├── ca 		   #后面没有明确使用这个文件夹里面的内容,应该是签发证书用的
│     ├── msp 		   #身份认证文件,主要是认证这个组织内orderer的身份,在启动时会被加载到orderer容器里面(也就是在搭建多机环境是这个文件是需要发给每个orderer的,不然它无法识别同组织的orderer)
│     ├── orderers 	   #里面存放每个orderer节点的相关信息
│     ├── tlsca
│     └── users 	   #用于存放user的身份(orderer组织只有一个ADMIN身份的用户)
└── peerOrganizations
   ├── Peer_fish.com
   │  ├── ca
   │  ├── msp
   │  ├── peers
   │  ├── tlsca
   │  └── users 	   #这里包含一个admin和一个普通的user
   └── Rest.com
      ├── ca
      ├── msp
      ├── peers
      ├── tlsca
      └── users

注意在注册身份(执行enroll.sh这个脚本)之前这些文件都是无用的,上述命令主要产生的是一个文件框架和一些非重要的文件
所以这里先不展开讲文件夹内文件的作用(因为在注册身份时会覆盖掉这些文件)

```

####开启ca服务
- 开启每个组织的ca服务端,为下一步的注册提供服务
- 这一步需要注意的是ca的用户名和密码,具体在compose\_ca.yaml这个文件里查看

####向ca注册相关身份
- 这是最麻烦的一步
- 相关过程见ca\_conf/enroll.sh 内有注释

####注册身份后的的各个组织的文件结构
```sh
#该文件目录唯一需要关心的是msp文件夹下面的cacerts文件夹和signcerts文件夹,这两个文件夹是会用于身份的认证与被认证,十分建议使用openssl工具查看一下这两个文件夹下面的pem文件
.
├── ca
│  ├── ca.Peer_fish.com-cert.pem
│  └── priv_sk
├── lsForPeerFis 	#该说明文件
├── msp
│  ├── admincerts
│  ├── cacerts
│  │  └── ca.Peer_fish.com-cert.pem
│  ├── config.yaml
│  └── tlscacerts
│     ├── ca.crt
│     └── tlsca.Peer_fish.com-cert.pem
├── peers 	#peer的身份用来验证网络中各个实体结构的身份
│  ├── peer0.Peer_fish.com
│  │  ├── msp
│  │  │  ├── admincerts 	#这个是1.x版本的遗留,2.x这个文件夹是没用的
│  │  │  ├── cacerts 		#理论上只需要一个文件但于是注册时没有覆盖掉所以这里的localhost-7054-ca-fish.pem是ca.Peer_fish.com-cert.pem的副本(由我手动覆盖),这个文件是用于验证身份
│  │  │  │  ├── ca.Peer_fish.com-cert.pem
│  │  │  │  └── localhost-7054-ca-fish.pem
│  │  │  ├── config.yaml
│  │  │  ├── IssuerPublicKey
│  │  │  ├── IssuerRevocationPublicKey
│  │  │  ├── keystore
│  │  │  │  ├── 505fbe18d5529ae0f91d80bb9a8db1f3019240ee87ab026ef192063b874b59ae_sk
│  │  │  │  └── priv_sk
│  │  │  ├── signcerts 		#用于证明身份(这里也有使用了手动覆盖的手段)
│  │  │  │  ├── cert.pem
│  │  │  │  └── peer0.Peer_fish.com-cert.pem
│  │  │  ├── tlscacerts 	#tls的证书
│  │  │  │  └── tlsca.Peer_fish.com-cert.pem
│  │  │  └── user
│  │  └── tls
│  │     ├── ca.crt
│  │     ├── cacerts
│  │     ├── IssuerPublicKey
│  │     ├── IssuerRevocationPublicKey
│  │     ├── keystore
│  │     │  └── caeaf790e2e14df2a26dbea5818f42153a690a5af83e88df65c41c644731b7ff_sk
│  │     ├── server.crt
│  │     ├── server.key
│  │     ├── signcerts
│  │     │  └── cert.pem
│  │     ├── tlscacerts
│  │     │  └── tls-localhost-7054-ca-fish.pem
│  │     └── user
│  └── peer1.Peer_fish.com 	#与peer0的结构一样
├── tlsca
│  ├── priv_sk
│  └── tlsca.Peer_fish.com-cert.pem
└── users 		#user用来验证对网络的操作的身份
   ├── Admin@Peer_fish.com
   │  ├── msp
   │  │  ├── admincerts
   │  │  ├── cacerts
   │  │  │  ├── ca.Peer_fish.com-cert.pem
   │  │  │  └── localhost-7054-ca-fish.pem
   │  │  ├── config.yaml
   │  │  ├── IssuerPublicKey
   │  │  ├── IssuerRevocationPublicKey
   │  │  ├── keystore
   │  │  │  ├── 5187b6ed5ad2e7514ae078f6444f1dba92d2120d6cfe14dd9b766f66f78e0d89_sk
   │  │  │  └── priv_sk
   │  │  ├── signcerts
   │  │  │  ├── Admin@Peer_fish.com-cert.pem
   │  │  │  └── cert.pem
   │  │  ├── tlscacerts
   │  │  │  └── tlsca.Peer_fish.com-cert.pem
   │  │  └── user
   │  └── tls
   │     ├── ca.crt
   │     ├── client.crt
   │     └── client.key
   └── User1@Peer_fish.com 	#与admin的结构一样

#总结就是:peer的身份会在开启网络的时候使用,user的身份会在部署应用与操作应用的时候使用
```

####启动网络
- 这里主要需要了解的是对给个节点的环境配置(详细说明在compose文件中有说明)
- 建议按照orderer -> peer+couch -> cli这个顺序查看配置说明

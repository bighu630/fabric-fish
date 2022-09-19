#指定这个变量,为了方便
fabricRest=/home/bighu/文档/区块链/fabric-Restaurant
#删除主机根目录下的一个配置文件(这个文件是下一条指令生成的,但是由于有三个组织,每个的不一样,并且他不会自动覆盖,所以要手动删除),也可以不删除然后在这个文件里修改ca项的ip和端口,这里选择删除,让它自动生成
rm ~/.fabric-ca-client/fabric-ca-client-config.yaml
#向ca-fish声明,这里的用户名和密码在compose_ca.yaml里面配置过,这一步就会产生上一步所说的文件
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-fish --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

#先指定位置写入这个文件,用来指示在验证身份时用到的证书,同时也标识了四类身份
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fish.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fish.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fish.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fish.pem
    OrganizationalUnitIdentifier: orderer' > ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/config.yaml

#将ca的证书拷贝到指定位置,相当于证书分发
cp ${fabricRest}/ca_conf/fish/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/tlscacerts/ca.crt

cp ${fabricRest}/ca_conf/fish/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/tlsca/tlsca.Peer_fish.com-cert.pem

cp ${fabricRest}/ca_conf/fish/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/ca/ca.Peer_fish.com-cert.pem

#提交身份申请,这里只是申请了这么一个身份(这个身份会在注册时用到),此时还没有产生这个身份的证书,只是有这个身份的用户名和密码
fabric-ca-client register --caname ca-fish --id.name fish_peer0 --id.secret fish_peer0pw --id.type peer --tls.certfiles "${fabricRest}/ca_conf/fish/ca-cert.pem"

fabric-ca-client register --caname ca-fish --id.name fish_peer1 --id.secret fish_peer1pw --id.type peer --tls.certfiles "${fabricRest}/ca_conf/fish/ca-cert.pem"

fabric-ca-client register --caname ca-fish --id.name fish_user --id.secret fish_userpw --id.type client --tls.certfiles "${fabricRest}/ca_conf/fish/ca-cert.pem"

fabric-ca-client register --caname ca-fish --id.name fish_admin --id.secret fish_adminpw --id.type admin --tls.certfiles "${fabricRest}/ca_conf/fish/ca-cert.pem"

#注册peer身份(这里需要注意-M后的属性,这会在这个文件夹里面生成相关的身份文件)
fabric-ca-client enroll -u https://fish_peer0:fish_peer0pw@localhost:7054 --caname ca-fish -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp --csr.hosts peer0.Peer_fish.com --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

#注册peer身份(带tls想选)
fabric-ca-client enroll -u https://fish_peer1:fish_peer1pw@localhost:7054 --caname ca-fish -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/msp --csr.hosts peer1.Peer_fish.com --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

#注册peer1的身份
fabric-ca-client enroll -u https://fish_peer0:fish_peer0pw@localhost:7054 --caname ca-fish -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls --enrollment.profile tls --csr.hosts peer0.Peer_fish.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

fabric-ca-client enroll -u https://fish_peer1:fish_peer1pw@localhost:7054 --caname ca-fish -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls --enrollment.profile tls --csr.hosts peer1.Peer_fish.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

#复制tls相关的证书文件,由于上述配置中使用了tls选项,所以在通信过程中需要进行tls验证(下面6行)
cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/ca.crt      

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/signcerts/*  ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/server.crt 

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/keystore/* ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/tls/server.key


cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls/ca.crt      

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls/signcerts/*  ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls/server.crt 

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls/keystore/* ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/tls/server.key

#这个config.yaml文件是至关重要的,他用来指示在验证身份时的cacerts,但是这所有的msp文件夹内文件的结构是一样的,所以同一组织可以使用同一个config.yaml文件
cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp/config.yaml

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/msp/config.yaml

#注册管理员和用户
fabric-ca-client enroll -u https://fish_user:fish_userpw@localhost:7054 --caname ca-fish -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/users/User1@Peer_fish.com/msp --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/users/User1@Peer_fish.com/msp/config.yaml

fabric-ca-client enroll -u https://fish_admin:fish_adminpw@localhost:7054 --caname ca-fish -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/users/Admin@Peer_fish.com/msp --tls.certfiles ${fabricRest}/ca_conf/fish/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/users/Admin@Peer_fish.com/msp/config.yaml

#注意该文件的最后几行


#同上
rm ~/.fabric-ca-client/fabric-ca-client-config.yaml
# ca-rest的配置
fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-rest --tls.certfiles ${fabricRest}/ca_conf/rest/ca-cert.pem

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rest.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rest.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rest.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-rest.pem
    OrganizationalUnitIdentifier: orderer' > ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/msp/config.yaml

cp ${fabricRest}/ca_conf/rest/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/msp/tlscacerts/ca.crt

cp ${fabricRest}/ca_conf/rest/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/tlsca/tlsca.Rest.com-cert.pem

cp ${fabricRest}/ca_conf/rest/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/ca/ca.Rest.com-cert.pem

fabric-ca-client register --caname ca-rest --id.name rest_peer0 --id.secret rest_peer0pw --id.type peer --tls.certfiles "${fabricRest}/ca_conf/rest/ca-cert.pem"

fabric-ca-client register --caname ca-rest --id.name rest_user --id.secret rest_userpw --id.type client --tls.certfiles "${fabricRest}/ca_conf/rest/ca-cert.pem"

fabric-ca-client register --caname ca-rest --id.name rest_admin --id.secret rest_adminpw --id.type admin --tls.certfiles "${fabricRest}/ca_conf/rest/ca-cert.pem"

fabric-ca-client enroll -u https://rest_peer0:rest_peer0pw@localhost:8054 --caname ca-rest -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp --csr.hosts peer0.Rest.com --tls.certfiles ${fabricRest}/ca_conf/rest/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp/config.yaml

fabric-ca-client enroll -u https://rest_peer0:rest_peer0pw@localhost:8054 --caname ca-rest -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls --enrollment.profile tls --csr.hosts peer0.Rest.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/rest/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/ca.crt      

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/signcerts/*  ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/server.crt 

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/keystore/* ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/tls/server.key

fabric-ca-client enroll -u https://rest_user:rest_userpw@localhost:8054 --caname ca-rest -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/users/User1@Rest.com/msp --tls.certfiles ${fabricRest}/ca_conf/rest/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/users/User1@Rest.com/msp/config.yaml

fabric-ca-client enroll -u https://rest_admin:rest_adminpw@localhost:8054 --caname ca-rest -M ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/users/Admin@Rest.com/msp --tls.certfiles ${fabricRest}/ca_conf/rest/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/users/Admin@Rest.com/msp/config.yaml







rm ~/.fabric-ca-client/fabric-ca-client-config.yaml
# orderer的配置
fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/config.yaml

cp ${fabricRest}/ca_conf/ordererca/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

cp ${fabricRest}/ca_conf/ordererca/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/tlsca/tlsca.fish.com-cert.pem

#cp ${fabricRest}/ca_conf/ordererca/ca-cert.pem ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/ca/ca.fish.com-cert.pem

fabric-ca-client register --caname ca-orderer --id.name fish_orderer --id.secret fish_ordererpw --id.type orderer --tls.certfiles "${fabricRest}/ca_conf/ordererca/ca-cert.pem"

fabric-ca-client register --caname ca-orderer --id.name fish_orderer1 --id.secret fish_orderer1pw --id.type orderer --tls.certfiles "${fabricRest}/ca_conf/ordererca/ca-cert.pem"
#没有user只有管理员
#fabric-ca-client register --caname ca-orderer --id.name fish_user --id.secret fish_userpw --id.type client --tls.certfiles "${fabricRest}/ca_conf/ordererca/ca-cert.pem"

fabric-ca-client register --caname ca-orderer --id.name fish_admin --id.secret fish_adminpw --id.type admin --tls.certfiles "${fabricRest}/ca_conf/ordererca/ca-cert.pem"

#################
fabric-ca-client enroll -u https://fish_orderer:fish_ordererpw@localhost:9054 --caname ca-orderer -M ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp --csr.hosts orderer.fish.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

fabric-ca-client enroll -u https://fish_orderer1:fish_orderer1pw@localhost:9054 --caname ca-orderer -M ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/msp --csr.hosts orderer1.fish.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/config.yaml

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/msp/config.yaml

fabric-ca-client enroll -u https://fish_orderer:fish_ordererpw@localhost:9054 --caname ca-orderer -M ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls --enrollment.profile tls --csr.hosts orderer.fish.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

fabric-ca-client enroll -u https://fish_orderer1:fish_orderer1pw@localhost:9054 --caname ca-orderer -M ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls --enrollment.profile tls --csr.hosts orderer1.fish.com --csr.hosts localhost --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/ca.crt      

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/signcerts/*  ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/server.crt 

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/keystore/* ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/server.key

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/ca.crt      

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/signcerts/*  ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/server.crt 

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/keystore/* ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/server.key

#fabric-ca-client enroll -u https://fish_user:fish_userpw@localhost:9054 --caname ca-orderer -M ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/users/User1@fish.com/msp --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

#cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/users/User1@fish.com/msp/config.yaml
cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/tls/tlscacerts/* ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/msp/tlscacerts/tlsca.fish.com-cert.pem

fabric-ca-client enroll -u https://fish_admin:fish_adminpw@localhost:9054 --caname ca-orderer -M ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/users/Admin@fish.com/msp --tls.certfiles ${fabricRest}/ca_conf/ordererca/ca-cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/config.yaml ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/users/Admin@fish.com/msp/config.yaml




#cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp/cacerts/localhost-7054-ca-fish.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/msp/cacerts

#cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp/cacerts/localhost-8054-ca-rest.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/msp/cacerts

#cp ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/msp/cacerts/localhost-9054-ca-orderer.pem ${fabricRest}/org_crypto_conf/organizations/ordererOrganizations/fish.com/msp/cacerts

#这里的每一步操作的复制源地址与复制的目的地址是在同一个文件夹里面,实际上只是对这个文件进行重命名,但值得注意的是在这个文件夹里面是存在一个与目的文件同名的文件,所以这里的复制相当于是覆盖,覆盖这个文件的原因是这个被覆盖的文件是使用工具默认生成的但是在注册身份的身份的时候不是直接覆盖,而是产生另外一个文件,可是在节点启动的时候它却使用了那个错误的默认文件

#具体可以使用 "openssl x509 -in ****.pem -text"查看,如果签名机构是***fabric***就是默认生成的无效证书,因为有效证书肯定是fish.com这类机构的

fabricRest=/home/bighu/文档/区块链/fabric-Restaurant

cp ../org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/signcerts/orderer.fish.com-cert.pem ../org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer.fish.com/msp/signcerts/cert.pem

cp ../org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/msp/signcerts/orderer1.fish.com-cert.pem ../org_crypto_conf/organizations/ordererOrganizations/fish.com/orderers/orderer1.fish.com/msp/signcerts/cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/users/Admin@Peer_fish.com/msp/signcerts/Admin@Peer_fish.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/users/Admin@Peer_fish.com/msp/signcerts/cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/users/Admin@Rest.com/msp/signcerts/Admin@Rest.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/users/Admin@Rest.com/msp/signcerts/cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp/cacerts/ca.Peer_fish.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp/cacerts/localhost-7054-ca-fish.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/msp/cacerts/ca.Peer_fish.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/msp/cacerts/localhost-7054-ca-fish.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/msp/signcerts/peer1.Peer_fish.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer1.Peer_fish.com/msp/signcerts/cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp/signcerts/peer0.Peer_fish.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Peer_fish.com/peers/peer0.Peer_fish.com/msp/signcerts/cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp/signcerts/peer0.Rest.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp/signcerts/cert.pem

cp ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp/cacerts/ca.Rest.com-cert.pem ${fabricRest}/org_crypto_conf/organizations/peerOrganizations/Rest.com/peers/peer0.Rest.com/msp/cacerts/localhost-8054-ca-rest.pem

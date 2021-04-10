export VERBOSE=false
. scripts/utils.sh

function tlsCA(){

#tls server start 
infoln "Start tlsCA with Docker "

export FABRIC_CA_SERVER_HOME=$HOME/testnet/crypto-config/fabric-ca/tls

infoln "Start tlsCA..."
docker-compose -f docker/docker-compose-tls-ca.yaml up -d

    while :
    do
      if [ ! -f "$HOME/testnet/crypto-config/fabric-ca/tls/ca-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done
    
docker ps 


}

function rootCA(){

mkdir -p $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca
mkdir -p $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-root-cert
cp $HOME/testnet/crypto-config/fabric-ca/tls/ca-cert.pem $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-root-cert/tls-ca-cert.pem

infoln "enroll tls-ca-admin"

export FABRIC_CA_CLIENT_HOME=$HOME/testnet/crypto-config/fabric-ca/fabric-ca-client

fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --enrollment.profile tls --csr.hosts fabric-ca --mspdir tls-ca/tlsadmin/msp

infoln "register rootCA admin"

fabric-ca-client register -d --id.name rcaadmin --id.secret rcaadmin -u https://fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --mspdir tls-ca/tlsadmin/msp

infoln "enroll rootCA admin"

fabric-ca-client enroll -d -u https://rcaadmin:rcaadmin@fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --enrollment.profile tls --csr.hosts fabric-ca --mspdir tls-ca/rcaadmin/msp

infoln "Register Intermediate CA org1_admin with the org1_admin TLS CA"

fabric-ca-client register -d --id.name org1_admin --id.secret org1_adminpw -u https://fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --mspdir tls-ca/tlsadmin/msp

infoln "Enroll Intermediate CA org1_admin with the org1_admin TLS CA"

fabric-ca-client enroll -d -u https://org1_admin:org1_adminpw@fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --enrollment.profile tls --csr.hosts fabric-ca --mspdir tls-ca/org1_admin/msp

infoln "Register Intermediate CA org2_admin with the org2_admin TLS CA"

fabric-ca-client register -d --id.name org2_admin --id.secret org2_adminpw -u https://fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --mspdir tls-ca/tlsadmin/msp

infoln "Enroll Intermediate CA org2_admin with the org2_admin TLS CA"

fabric-ca-client enroll -d -u https://org2_admin:org2_adminpw@fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --enrollment.profile tls --csr.hosts fabric-ca --mspdir tls-ca/org2_admin/msp

infoln "Register Intermediate CA ordererOrg_admin with the ordererOrg_admin TLS CA"

fabric-ca-client register -d --id.name ordererOrg_admin --id.secret ordererOrg_adminpw -u https://fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --mspdir tls-ca/tlsadmin/msp

infoln "Enroll Intermediate CA ordererOrg_admin with the ordererOrg_admin TLS CA"

fabric-ca-client enroll -d -u https://ordererOrg_admin:ordererOrg_adminpw@fabric-ca:10054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --enrollment.profile tls --csr.hosts fabric-ca --mspdir tls-ca/ordererOrg_admin/msp


infoln "Start rootCA with Docker "

export FABRIC_CA_SERVER_HOME=$HOME/testnet/crypto-config/fabric-ca/root

mkdir -p $HOME/testnet/crypto-config/fabric-ca/root/tls

cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/rcaadmin/msp/signcerts/cert.pem $HOME/testnet/crypto-config/fabric-ca/root/tls && cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/rcaadmin/msp/keystore/* $HOME/testnet/crypto-config/fabric-ca/root/tls/key.pem

infoln "Start rootCA..."
docker-compose -f docker/docker-compose-rootCA.yaml up -d

while :
    do
      if [ ! -f "$HOME/testnet/crypto-config/fabric-ca/root/ca-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done
docker ps 

}

function org1CA(){


mkdir -p $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/root-ca

export FABRIC_CA_CLIENT_HOME=$HOME/testnet/crypto-config/fabric-ca/fabric-ca-client

fabric-ca-client enroll -d -u https://rcaadmin:rcaadminpw@fabric-ca:6054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --csr.hosts fabric-ca --mspdir root-ca/rcaadmin/msp

infoln "register and enroll the Intermediate org1 CA admin with the org1 TLS CA"

fabric-ca-client register -d --id.name org1_admin --id.secret org1_adminpw -u https://fabric-ca:6054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --id.attrs '"hf.Registrar.Roles=user,admin","hf.Revoker=true","hf.IntermediateCA=true"' --mspdir root-ca/rcaadmin/msp

infoln "register and enroll the Intermediate org2 CA admin with the org2 TLS CA"

fabric-ca-client register -d --id.name org2_admin --id.secret org2_adminpw -u https://fabric-ca:6054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --id.attrs '"hf.Registrar.Roles=user,admin","hf.Revoker=true","hf.IntermediateCA=true"' --mspdir root-ca/rcaadmin/msp

infoln "register and enroll the Intermediate orderer CA admin with the ordererOrg TLS CA"

fabric-ca-client register -d --id.name ordererOrg_admin --id.secret ordererOrg_adminpw -u https://fabric-ca:6054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --id.attrs '"hf.Registrar.Roles=user,admin","hf.Revoker=true","hf.IntermediateCA=true"' --mspdir root-ca/rcaadmin/msp


infoln "Start Org1CA with Docker "

#Deploy an intermediate Org1 CA
mkdir -p $HOME/testnet/crypto-config/fabric-ca/org1/tls
export FABRIC_CA_SERVER_HOME=$HOME/testnet/crypto-config/fabric-ca/org1

cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/org1_admin/msp/signcerts/cert.pem $HOME/testnet/crypto-config/fabric-ca/org1/tls && cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/org1_admin/msp/keystore/* $HOME/testnet/crypto-config/fabric-ca/org1/tls/key.pem

cp $HOME/testnet/crypto-config/fabric-ca/tls/ca-cert.pem $HOME/testnet/crypto-config/fabric-ca/org1/tls/tls-ca-cert.pem

infoln "Start Org1CA..."

docker-compose -f docker/docker-compose-org1CA.yaml up -d

}

function org2CA(){


infoln "Start Org2CA with Docker "

#Deploy an intermediate Org2 CA
mkdir -p $HOME/testnet/crypto-config/fabric-ca/org2/tls
export FABRIC_CA_SERVER_HOME=$HOME/testnet/crypto-config/fabric-ca/org2

cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/org2_admin/msp/signcerts/cert.pem $HOME/testnet/crypto-config/fabric-ca/org2/tls && cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/org2_admin/msp/keystore/* $HOME/testnet/crypto-config/fabric-ca/org2/tls/key.pem

cp $HOME/testnet/crypto-config/fabric-ca/tls/ca-cert.pem $HOME/testnet/crypto-config/fabric-ca/org2/tls/tls-ca-cert.pem

infoln "Start Org2CA..."

docker-compose -f docker/docker-compose-org2CA.yaml up -d

}


function ordererOrgCA(){

#Start OrdererOrgCA with Docker 
infoln "StartOrdererOrgCA with Docker "

#Deploy an intermediate OrdererOrg CA
mkdir -p $HOME/testnet/crypto-config/fabric-ca/ordererOrg/tls
export FABRIC_CA_SERVER_HOME=$HOME/testnet/crypto-config/fabric-ca/ordererOrg

cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/ordererOrg_admin/msp/signcerts/cert.pem $HOME/testnet/crypto-config/fabric-ca/ordererOrg/tls && cp $HOME/testnet/crypto-config/fabric-ca/fabric-ca-client/tls-ca/ordererOrg_admin/msp/keystore/* $HOME/testnet/crypto-config/fabric-ca/ordererOrg/tls/key.pem

cp $HOME/testnet/crypto-config/fabric-ca/tls/ca-cert.pem $HOME/testnet/crypto-config/fabric-ca/ordererOrg/tls/tls-ca-cert.pem

infoln "Start OrdererOrg CA..."
docker-compose -f docker/docker-compose-ordererOrgCA.yaml up -d

}

MODE=$1
PEER_NUM=$2

if [ "$MODE" == "tlsCA" ]; then
  tlsCA
elif [ "$MODE" == "rootCA" ]; then
  rootCA
elif [ "$MODE" == "orgCA" ]; then
  org1CA
  
  while :
    do
      if [ ! -f "$HOME/testnet/crypto-config/fabric-ca/org1/ca-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done
     
  org2CA
  
  while :
    do
      if [ ! -f "$HOME/testnet/crypto-config/fabric-ca/org2/ca-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done
    
  ordererOrgCA
  
  while :
    do
      if [ ! -f "$HOME/testnet/crypto-config/fabric-ca/ordererOrg/ca-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done
    
    docker ps
fi

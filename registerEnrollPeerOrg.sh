#!/bin/bash

./utils/helper.sh

setClientHome() {
  ORG_DOMAIN=$1
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${ORG_DOMAIN}/
}

CAAdminEnroll() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  echo ">> Enroll CA Admin for $DOMAIN"
  setClientHome $DOMAIN
  fabric-ca-client enroll -u https://admin:adminpw@localhost:$PORT \
    --caname ca.$DOMAIN \
    --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem
}

registerIdentities() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  PEERPW=$4
  ADMINPW=$5
  USERPW=$6
  setClientHome $DOMAIN

  echo ">> Register peer0"
  fabric-ca-client register --caname ca.$DOMAIN --id.name peer0 --id.secret $PEERPW --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem

  echo ">> Register org admin"
  fabric-ca-client register --caname ca.$DOMAIN --id.name ${ORG}admin --id.secret $ADMINPW --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem

  echo ">> Register user1"
  fabric-ca-client register --caname ca.$DOMAIN --id.name user1 --id.secret $USERPW --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem
}

peerMSPEnroll() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  PEERPW=$4
  echo ">> Enroll peer0 MSP for $DOMAIN"
  fabric-ca-client enroll -u https://peer0:$PEERPW@localhost:$PORT --caname ca.$DOMAIN \
    -M ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/msp \
    --csr.hosts peer0.$DOMAIN \
    --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem
}

peerTLSEnroll() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  PEERPW=$4
  echo ">> Enroll peer0 TLS for $DOMAIN"
  fabric-ca-client enroll -u https://peer0:$PEERPW@localhost:$PORT --caname ca.$DOMAIN \
    -M ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls \
    --enrollment.profile tls \
    --csr.hosts peer0.$DOMAIN --csr.hosts localhost \
    --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem

  cp ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls/signcerts/* ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls/keystore/* ${PWD}/organizations/peerOrganizations/$DOMAIN/peers/peer0.$DOMAIN/tls/server.key
}

adminOrgEnroll() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  ADMINPW=$4
  echo ">> Enroll org admin for $DOMAIN"
  fabric-ca-client enroll -u https://${ORG}admin:$ADMINPW@localhost:$PORT --caname ca.$DOMAIN \
    -M ${PWD}/organizations/peerOrganizations/$DOMAIN/users/Admin@$DOMAIN/msp \
    --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem
}

userEnroll() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  USERPW=$4
  echo ">> Enroll user1 for $DOMAIN"
  fabric-ca-client enroll -u https://user1:$USERPW@localhost:$PORT --caname ca.$DOMAIN \
    -M ${PWD}/organizations/peerOrganizations/$DOMAIN/users/User1@$DOMAIN/msp \
    --tls.certfiles ${PWD}/organizations/fabric-ca/$ORG/ca-cert.pem
}

generateConfigYaml() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  CERT_DOMAIN=$(echo "${DOMAIN}" | sed 's/\./-/g')

  echo ">> Generate NodeOUs config.yaml for $DOMAIN"
  CONFIG_PATH=${PWD}/organizations/peerOrganizations/${DOMAIN}/msp
  mkdir -p $CONFIG_PATH

  cat <<EOF > ${CONFIG_PATH}/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${CERT_DOMAIN}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${CERT_DOMAIN}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${CERT_DOMAIN}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-ca-${CERT_DOMAIN}.pem
    OrganizationalUnitIdentifier: orderer
EOF

  cp ${CONFIG_PATH}/config.yaml ${PWD}/organizations/peerOrganizations/${DOMAIN}/peers/peer0.${DOMAIN}/msp/config.yaml
  cp ${CONFIG_PATH}/config.yaml ${PWD}/organizations/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/config.yaml
}

# ====================================================
# 🚀 Execute for each org
# Usage: <ORG_NAME> <ORG_DOMAIN> <PORT> <peerPW> <adminPW> <userPW>
# ====================================================
processOrg() {
  ORG=$1
  DOMAIN=$2
  PORT=$3
  PEERPW=$4
  ADMINPW=$5
  USERPW=$6

  CAAdminEnroll $ORG $DOMAIN $PORT
  registerIdentities $ORG $DOMAIN $PORT $PEERPW $ADMINPW $USERPW
  peerMSPEnroll $ORG $DOMAIN $PORT $PEERPW
  peerTLSEnroll $ORG $DOMAIN $PORT $PEERPW
  adminOrgEnroll $ORG $DOMAIN $PORT $ADMINPW
  userEnroll $ORG $DOMAIN $PORT $USERPW
  generateConfigYaml $ORG $DOMAIN $PORT
}

# Run for Org1 and Org2
processOrg "org1" "org1.example.com" "7054" "peer0pw" "org1adminpw" "user1pw"
processOrg "org2" "org2.example.com" "8054" "peer0pw" "org2adminpw" "user1pw"

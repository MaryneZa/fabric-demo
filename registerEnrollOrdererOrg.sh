processOrdererOrg() {
  ORG="ordererOrg"
  DOMAIN="example.com"
  PORT="9054"
  ORDERER_NAME="orderer1"
  ORDERER_PW="orderer1pw"
  ADMIN_NAME="ordererAdmin"
  ADMIN_PW="ordererAdminpw"
  USER_NAME="ordererUser"
  USER_PW="ordererUserpw"
  CERT_DOMAIN=$(echo "orderer.${DOMAIN}" | sed 's/\./-/g')
  

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/${DOMAIN}/

  echo ">> Enroll Orderer CA Admin"
  fabric-ca-client enroll -u https://admin:adminpw@localhost:$PORT \
    --caname ca.orderer.${DOMAIN} \
    --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/ca-cert.pem

  echo ">> Register $ORDERER_NAME"
  fabric-ca-client register --caname ca.orderer.${DOMAIN} \
    --id.name $ORDERER_NAME --id.secret $ORDERER_PW --id.type orderer \
    --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/ca-cert.pem

  echo ">> Register Admin"
  fabric-ca-client register --caname ca.orderer.${DOMAIN} \
    --id.name $ADMIN_NAME --id.secret $ADMIN_PW --id.type admin \
    --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/ca-cert.pem

  echo ">> Enroll Orderer MSP"
  fabric-ca-client enroll -u https://${ORDERER_NAME}:${ORDERER_PW}@localhost:$PORT \
    --caname ca.orderer.${DOMAIN} \
    -M ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/msp \
    --csr.hosts ${ORDERER_NAME}.${DOMAIN} --csr.hosts localhost \
    --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/ca-cert.pem

  echo ">> Enroll Orderer TLS"
  fabric-ca-client enroll -u https://${ORDERER_NAME}:${ORDERER_PW}@localhost:$PORT \
    --caname ca.orderer.${DOMAIN} \
    -M ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls \
    --enrollment.profile tls \
    --csr.hosts ${ORDERER_NAME}.${DOMAIN} --csr.hosts localhost \
    --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/ca-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls/tlscacerts/* \
     ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls/signcerts/* \
     ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls/keystore/* \
     ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/tls/server.key

  echo ">> Enroll Orderer Admin"
  fabric-ca-client enroll -u https://${ADMIN_NAME}:${ADMIN_PW}@localhost:$PORT \
    --caname ca.orderer.${DOMAIN} \
    -M ${PWD}/organizations/ordererOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp \
    --tls.certfiles ${PWD}/organizations/fabric-ca/${ORG}/ca-cert.pem


  echo ">> Generate config.yaml for Orderer"
  cat <<EOF > ${PWD}/organizations/ordererOrganizations/${DOMAIN}/msp/config.yaml
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


  cp ${PWD}/organizations/ordererOrganizations/${DOMAIN}/msp/config.yaml \
     ${PWD}/organizations/ordererOrganizations/${DOMAIN}/orderers/${ORDERER_NAME}.${DOMAIN}/msp/config.yaml

  cp ${PWD}/organizations/ordererOrganizations/${DOMAIN}/msp/config.yaml \
     ${PWD}/organizations/ordererOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/config.yaml
}

processOrdererOrg
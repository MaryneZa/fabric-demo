#!/bin/bash

. scripts/utils.sh

# Set environment for fabric-ca-client -- for org1
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

# Enroll CA Admin (Bootstrap identity)
# This creates the base MSP folder
# organizations/peerOrganizations/org1.example.com/msp/
CAAdminEnroll(){
  echo ">> Enroll CA Admin (Bootstrap identity)"
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.org1.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Register peer0
peerRegistier(){
  echo ">> Register peer"
  fabric-ca-client register --caname ca.org1.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Register org admin
adminOrgRegister(){
  echo ">> Register org admin"
  fabric-ca-client register --caname ca.org1.example.com --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Register user1
userRegister(){
  echo ">> Register user1"
  fabric-ca-client register --caname ca.org1.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Enroll peer0 (MSP)
peerMSPEnroll(){
  echo ">> Enroll peer0 (MSP)"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.org1.example.com -M ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp --csr.hosts peer0.org1.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Enroll peer0 (TLS)
peerTLSEnroll(){
  echo ">> Enroll peer0 (TLS)"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.org1.example.com -M ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls --enrollment.profile tls --csr.hosts peer0.org1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Enroll org admin
adminOrgEnroll(){
  echo ">> Enroll org admin"
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca.org1.example.com -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# Enroll user1
userEnroll(){
  echo ">> Enroll user1"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.org1.example.com -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca-cert.pem
}

# finally you will get these folder under peer0
# peer0.org1.example.com/
# ├── msp/
# └── tls/

# CAAdminEnroll

# peerRegistier
# adminOrgRegister
# userRegister

# peerMSPEnroll
# peerTLSEnroll
# adminOrgEnroll
# userEnroll




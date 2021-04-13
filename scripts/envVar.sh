#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/wizchain.net/orderers/orderer0.wizchain.net/msp/tlscacerts/tlsca.wizchain.net-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.wizchain.net/peers/peer0.org1.wizchain.net/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.wizchain.net/peers/peer1.org1.wizchain.net/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.wizchain.net/peers/peer0.org2.wizchain.net/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.wizchain.net/peers/peer0.org2.wizchain.net/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/crypto-config/peerOrganizations/org3.wizchain.net/peers/peer0.org3.wizchain.net/tls/ca.crt

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 0 ]; then
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=crypto-config/peerOrganizations/org1.wizchain.net/peers/peer0.org1.wizchain.net/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=crypto-config/peerOrganizations/org1.wizchain.net/users/Admin@org1.wizchain.net/msp
    export CORE_PEER_ADDRESS=peer0.org1.wizchain.net:7051
  elif [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=crypto-config/peerOrganizations/org1.wizchain.net/peers/peer1.org1.wizchain.net/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=crypto-config/peerOrganizations/org1.wizchain.net/users/Admin@org1.wizchain.net/msp
    export CORE_PEER_ADDRESS=peer1.org1.wizchain.net:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=crypto-config/peerOrganizations/org2.wizchain.net/peers/peer0.org2.wizchain.net/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=crypto-config/peerOrganizations/org2.wizchain.net/users/Admin@org2.wizchain.net/msp
    export CORE_PEER_ADDRESS=peer0.org2.wizchain.net:7051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=crypto-config/peerOrganizations/org2.wizchain.net/peers/peer3.org2.wizchain.net/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=crypto-config/peerOrganizations/org2.wizchain.net/users/Admin@org2.wizchain.net/msp
    export CORE_PEER_ADDRESS=peer3.org2.wizchain.net:7051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 0 ]; then
    export CORE_PEER_ADDRESS=peer0.org1.wizchain.net:7051
  elif [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer1.org1.wizchain.net:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.org2.wizchain.net:7051  
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer3.org2.wizchain.net:7051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    if [ $1 -eq 0 ]; then
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses peer0.org1.wizchain.net:7051 --tlsRootCertFiles crypto-config/peerOrganizations/org1.wizchain.net/peers/peer0.org1.wizchain.net/tls/ca.crt"
    elif [ $1 -eq 1 ]; then
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses peer1.org1.wizchain.net:7051 --tlsRootCertFiles crypto-config/peerOrganizations/org1.wizchain.net/peers/peer1.org1.wizchain.net/tls/ca.crt"
    elif [ $1 -eq 2 ]; then 
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses peer0.org2.wizchain.net:7051 --tlsRootCertFiles crypto-config/peerOrganizations/org2.wizchain.net/peers/peer0.org2.wizchain.net/tls/ca.crt"
    elif [ $1 -eq 3 ]; then
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses peer3.org2.wizchain.net:7051 --tlsRootCertFiles crypto-config/peerOrganizations/org2.wizchain.net/peers/peer3.org2.wizchain.net/tls/ca.crt"
    fi
#    PEER="peer0.org$1"
#    ## Set peer addresses
#    PEERS="$PEERS $PEER"
#    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
#    ## Set path to TLS certificate
#    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
#    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

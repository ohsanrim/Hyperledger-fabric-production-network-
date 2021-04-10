export VERBOSE=false
. scripts/utils.sh

#!/bin/bash
## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  TYPE=$2
  shift
fi


if [ "${MODE}" == "start" ]; then
  echo "networkUp"

  IMAGE_TAG=$IMAGETAG docker-compose -f ${PWD}/docker/docker-compose-couch.yaml up -d 2>&1

  echo $(sleep 3)

  docker ps -a
  
  if [ "${TYPE}" == "peer" ]; then
  
    infoln "peer start..."
    
    peer node start >& ./test.log &
  
  elif  [ "${TYPE}" == "orderer" ]; then
  
    infoln "orderer start..."
    
    orderer start >& ./test.log &
  
  fi
  
  #peer node start >& ./test.log &

elif [ "${MODE}" == "stop" ]; then

  echo "networkDown"

  #kill $(ps -ef | grep -v grep | grep -v /bin/sh | grep "peer" | awk '{print $2}')
  
  if [ "${TYPE}" == "peer" ]; then
    infoln "peer stop..."
    kill $(ps -ef | grep -v grep | grep -v /bin/sh | grep "peer" | awk '{print $2}')
  
  elif  [ "${TYPE}" == "orderer" ]; then
    infoln "orderer stop..."
    kill $(ps -ef | grep -v grep | grep -v /bin/sh | grep "orderer" | awk '{print $2}')
  
  fi
  
  docker-compose -f ${PWD}/docker/docker-compose-couch.yaml down --volumes --remove-orphans

elif [ "${MOD}" == "create" ]; then

  echo "start fabric node"

  ./network.sh up –ca –t peer0

else
  exit 1
fi

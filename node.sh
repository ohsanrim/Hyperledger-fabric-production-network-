#!/bin/bash
## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi


if [ "${MODE}" == "start" ]; then
  echo "networkUp"

  IMAGE_TAG=$IMAGETAG docker-compose -f ${PWD}/docker/docker-compose-couch.yaml up -d 2>&1

  echo $(sleep 3)

  docker ps -a

  peer node start >& ./test.log &

elif [ "${MODE}" == "stop" ]; then

  echo "networkDown"

  kill $(ps -ef | grep -v grep | grep -v /bin/sh | grep "peer" | awk '{print $2}')

  docker-compose -f ${PWD}/docker/docker-compose-couch.yaml down --volumes --remove-orphans

elif [ "${MOD}" == "create" ]; then

  echo "start fabric node"

  ./network.sh up –ca –t peer0

else
  exit 1
fi

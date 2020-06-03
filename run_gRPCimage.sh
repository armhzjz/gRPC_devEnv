#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

USERID=1000
GROUPID=100
WORKDIR=${SCRIPTDIR}/grpc_workdir

if [ -z "$1" ]; then
    DOCKER_IMAGE=grpc
    DOCKER_IMAGE_TAG=1.28.1
elif [ -z "$2"]; then
    echo "ERROR: script must receive either two arguments (i.e. image and image_tag) or none"
    exit -1
else
    DOCKER_IMAGE="$1"
    DOCKER_IMAGE_TAG="$2"
fi



mkdir -p ${WORKDIR}
docker run -it --rm --network=host --user ${USERID}:${GROUPID} -v ${WORKDIR}:/data ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG} /bin/bash
#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

docker build --rm --network=host -t grpc:1.28.1 -f ${SCRIPTDIR}/Dockerfile ${SCRIPTDIR}
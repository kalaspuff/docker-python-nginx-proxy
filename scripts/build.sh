#!/usr/bin/env bash

if [[ $1 == "latest" ]]; then
    TAG="latest"
else
    TAG=`cat VERSION | xargs`
fi

EXPERIMENTAL=`docker info |grep Experimental|sed 's/Experimental: //' | xargs`
NAME="kalaspuff/tomodachi-nginx"

EXTRAOPTIONS=""
if [[ $EXPERIMENTAL != "" ]]; then
    EXTRAOPTIONS="--squash"
fi

if [ "$TAG" == "latest" ]; then
    docker build -t $NAME:latest -f Dockerfile --compress $EXTRAOPTIONS .
else
    docker build -t $NAME:$TAG -f Dockerfile --label version=$TAG --compress $EXTRAOPTIONS .
    docker tag $NAME:$TAG $NAME:latest
fi

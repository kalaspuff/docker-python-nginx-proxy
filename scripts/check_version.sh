#!/usr/bin/env bash

NAME="kalaspuff/python-nginx-proxy"
TAG=`cat VERSION | xargs`

EXISTS=`docker 2>&1 pull $NAME:$TAG | grep 'Digest: '`

if [[ $EXISTS != "" ]]; then
    echo "Version already released: $NAME:$TAG"
    exit 1
fi

#!/usr/bin/env bash

NAME="kalaspuff/python-nginx-proxy"
TAG=`cat VERSION | xargs`

docker push $NAME:$TAG
docker push $NAME:latest

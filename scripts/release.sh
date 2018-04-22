#!/usr/bin/env bash

NAME="kalaspuff/tomodachi-nginx"
TAG=`cat VERSION | xargs`

docker push $NAME:$TAG
docker push $NAME:latest

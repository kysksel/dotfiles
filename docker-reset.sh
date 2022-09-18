#!/bin/bash

RUNNING_CONTAINERS=`docker ps -aq`
if [[ $RUNNING_CONTAINERS ]]; then
    docker stop $RUNNING_CONTAINERS
    docker rm -f $RUNNING_CONTAINERS
fi

docker network prune -f

DOCKER_TEMP_IMAGES=`docker images --filter dangling=true -qa`
if [[ $DOCKER_TEMP_IMAGES ]]; then
    docker rmi -f DOCKER_TEMP_IMAGES
fi

DOCKER_TEMP_VOLUMES=`docker volume ls --filter dangling=true -q`
if [[ $DOCKER_TEMP_VOLUMES ]]; then
    docker volume rm -f $DOCKER_TEMP_VOLUMES
fi

DOCKER_ALL_IMAGES=`docker images -qa`
if [[ $DOCKER_ALL_IMAGES ]]; then
    docker rmi -f $DOCKER_ALL_IMAGES
fi

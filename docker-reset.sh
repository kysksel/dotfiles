#!/usr/bin/env bash

[ $(docker ps | wc -l) -ne 1 ] && echo "Stopping all containers..." && docker stop $(docker ps | sed -n '1d;p' | awk -F" " '{print $1}')
[ $(docker ps -a | wc -l) -ne 1 ] && echo "Deleting all containers..." && docker rm $(docker ps -a | sed -n '1d;p' | awk -F" " '{print $1}')
[ $(docker images | wc -l) -ne 1 ] && echo "Deleting all images..." && docker image rm $(docker images | sed -n '1d;p' | awk -F" " '{print $3}')
echo "Pruning networks, volumes, and cache..." && docker system prune -a -f --volumes

# RUNNING_CONTAINERS=`docker ps -aq`
# if [[ $RUNNING_CONTAINERS ]]; then
#     docker stop $RUNNING_CONTAINERS
#     docker rm -f $RUNNING_CONTAINERS
# fi

# docker network prune -f

# DOCKER_TEMP_IMAGES=`docker images --filter dangling=true -qa`
# if [[ $DOCKER_TEMP_IMAGES ]]; then
#     docker rmi -f DOCKER_TEMP_IMAGES
# fi

# DOCKER_TEMP_VOLUMES=`docker volume ls --filter dangling=true -q`
# if [[ $DOCKER_TEMP_VOLUMES ]]; then
#     docker volume rm -f $DOCKER_TEMP_VOLUMES
# fi

# DOCKER_ALL_IMAGES=`docker images -qa`
# if [[ $DOCKER_ALL_IMAGES ]]; then
#     docker rmi -f $DOCKER_ALL_IMAGES
# fi

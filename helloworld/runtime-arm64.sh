#!/bin/sh

# Make sure we have the latest runtime up and running
docker pull cscix65g/swift-runtime:arm64-latest
docker pull cscix65g/helloworld:arm64-latest
if [ ! "$(docker ps --all -q -f name=swift_runtime)" ]; then
    echo "Launching swift_runtime"

    if [ "$(docker volume ls | grep swift_runtime_usr_bin)" ]; then
	docker volume rm swift_runtime_usr_bin >> /dev/null
    fi
    docker volume create swift_runtime_usr_bin

    if [ "$(docker volume ls | grep swift_runtime_usr_lib)" ]; then
	docker volume rm swift_runtime_usr_lib >> /dev/null
    fi
    docker volume create swift_runtime_usr_lib

    if [ "$(docker volume ls | grep swift_runtime_lib)" ]; then
	docker volume rm swift_runtime_lib >> /dev/null
    fi
    docker volume create swift_runtime_lib

    if [ "$(docker volume ls | grep swift_debug)" ]; then
	docker volume rm swift_debug >> /dev/null
    fi
    docker volume create swift_debug

    # NB this command will print "Successful launch!" and exit
    # but will NOT remove the docker container
    docker run \
           --detach \
           --name swift_runtime \
           -v swift_runtime_lib:/lib \
           -v swift_runtime_usr_lib:/usr/lib \
           -v swift_runtime_usr_bin:/usr/bin \
           cscix65g/swift-runtime:arm64-latest
    docker logs swift_runtime
fi



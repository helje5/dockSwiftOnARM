#!/bin/sh
docker pull cscix65g/swift-runtime:arm64-latest
if [ ! "$(docker ps --all -q -f name=swift_runtime)" ]; then
    echo "Launching swift_runtime"
    docker run --name swift_runtime -d cscix65g/swift-runtime:arm64-latest
    docker logs swift_runtime
fi
docker run --rm -d --name echoserver -p 8080:8080 --volumes-from swift_runtime echoserver:arm64-latest

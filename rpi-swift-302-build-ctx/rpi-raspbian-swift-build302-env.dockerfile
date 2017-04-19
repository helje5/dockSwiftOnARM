# Dockerfile
#
# Just copy in Swift 3.0.2 to avoid the overhead when playing with the
# compile.

FROM helje5/rpi-raspbian-swift-build-env

ENV DEBIAN_FRONTEND noninteractive

ADD swift-3.0.2-RELEASE.tgz /swiftsrc

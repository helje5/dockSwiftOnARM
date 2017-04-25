# Dockerfile
#
# Just copy in Swift 3.1.1 to avoid the overhead when playing with the
# compile.

FROM helje5/rpi-ubuntu-swift-build-env

ADD swift-3.1.1-RELEASE.tgz /swiftsrc

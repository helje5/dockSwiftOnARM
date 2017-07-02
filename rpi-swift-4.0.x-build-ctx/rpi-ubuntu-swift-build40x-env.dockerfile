# Dockerfile
#
# Just copy in Swift 4.0.x snapshot to avoid the overhead when playing with the
# compile.

FROM helje5/rpi-ubuntu-swift-build-env

ADD swift-4.0-branch.tgz /swiftsrc

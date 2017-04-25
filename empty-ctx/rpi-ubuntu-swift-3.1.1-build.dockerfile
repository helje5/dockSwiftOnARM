# Dockerfile
#
# docker run --rm --interactive --tty helje5/rpi-ubuntu-swift-build311-env bash
#
# 2017-04-25: @ffried says only those two should be necessary for 3.1.1:
# https://github.com/swift-arm/swift-llvm/commit/95581a28b69cc7ea811055891b499576fdfc8ed7
# https://github.com/apple/swift-corelibs-libdispatch/pull/233/commits/d53fe63ef8ab88018bec940d067ae965144e2dab
#

FROM helje5/rpi-ubuntu-swift-build311-env

# swiftsrc is in /swiftsrc
WORKDIR /swiftsrc

RUN bash -c "curl -L -o swift-llvm-fdfc8ed7.diff https://github.com/swift-arm/swift-llvm/commit/95581a28b69cc7ea811055891b499576fdfc8ed7.diff;\
             curl -L -o swift-corelibs-libdispatch-233.diff https://github.com/apple/swift-corelibs-libdispatch/pull/233.diff"
             
RUN bash -c "cd swift-corelibs-libdispatch && \
             patch -l -p1 < ../swift-corelibs-libdispatch-233.diff; \
             cd ..; \
             cd llvm && \
             patch -l -p1 < ../swift-llvm-fdfc8ed7.diff"

ENV SWIFT_SOURCE_ROOT /swiftsrc

RUN ./build.sh

# the results will be in
#   /swiftsrc/install/usr/[bin|include|lib|libexec|local|share]

WORKDIR /swiftsrc/install/usr/

VOLUME /package

# takes ~4mins on RPi3, ~122MB (BZip2 takes ~8mins on RPi3, saves 12MB)
RUN tar zcf "/package/swift-3.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *

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


# embedded buildSwiftOnArm

ENV REL=3.1.1 INSTALL_DIR=$PWD/install PACKAGE=$PWD/swift-${REL}.tgz

RUN ./swift/utils/build-script --build-subdir buildbot_linux -R \
        --lldb --llbuild --xctest --swiftpm --foundation --libdispatch \
        -- --install-libdispatch --install-foundation --install-swift \
        --install-lldb --install-llbuild --install-xctest --install-swiftpm \
        --install-prefix=/usr \
        '--swift-install-components=autolink-driver;compiler;clang-builtin-headers;stdlib;swift-remote-mirror;sdk-overlay;dev' \
        --build-swift-static-stdlib --build-swift-static-sdk-overlay \
        --install-destdir=$INSTALL_DIR --installable-package=$PACKAGE

# echo "+ Fixing up the install package for ARM"
RUN bash -c "\
  cp -R swift-corelibs-libdispatch/dispatch/ ${INSTALL_DIR}/usr/lib/swift; \
  cp ./build/buildbot_linux/libdispatch-linux-armv7/src/swift/Dispatch.swiftdoc \
     ${INSTALL_DIR}/usr/lib/swift/linux/armv7/; \
  cp ./build/buildbot_linux/libdispatch-linux-armv7/src/swift/Dispatch.swiftmodule \
     ${INSTALL_DIR}/usr/lib/swift/linux/armv7/; \
  cp ./build/buildbot_linux/libdispatch-linux-armv7/src/libdispatch.la \
     ${INSTALL_DIR}/usr/lib/swift/linux/; \
  cp ./build/buildbot_linux/libdispatch-linux-armv7/src/.libs/libdispatch.so \
     ${INSTALL_DIR}/usr/lib/swift/linux; \
  mkdir -p ${INSTALL_DIR}/usr/lib/swift/os; \
  cp swift-corelibs-libdispatch/os/linux_base.h ${INSTALL_DIR}/usr/lib/swift/os; \
  cp swift-corelibs-libdispatch/os/object.h ${INSTALL_DIR}/usr/lib/swift/os \
"

# Retar
# echo "+ Retar installation package"
RUN tar -C ${INSTALL_DIR} -czf ${PACKAGE} .


# the results will be in
#   /swiftsrc/install/usr/[bin|include|lib|libexec|local|share]

WORKDIR /swiftsrc/install/usr/

VOLUME /package

# takes ~4mins on RPi3, ~122MB (BZip2 takes ~8mins on RPi3, saves 12MB)
RUN tar zcf "/package/swift-3.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *

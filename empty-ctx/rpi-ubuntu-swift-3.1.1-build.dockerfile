# Dockerfile
#
# docker run --rm -i --tty helje5/rpi-ubuntu-swift-build311-env bash
# 
# TODO: need a script within the image for this:
# docker run --rm -v /home/pirate:/package helje5/rpi-ubuntu-swift311-build \
#   tar zcf '/package/swift-3.1.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz' *
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


# this fails because the script patches the PYTHONPATH so that
# swiftsrc/swift/utils is before swiftsrc/swift/utils/swift_build_support
# (and hence picks up the duplicate swift_build_support directory)
# sys.path.append(os.path.dirname(__file__)) ...
RUN bash -c "mv swift/utils/build-script swift/utils/build-script.orig;   \
             cat swift/utils/build-script.orig \
             | sed '/import sys/a sys.path.append(os.path.join(os.path.dirname(__file__), \"swift_build_support\"))' \
             | sed '/import sys/a sys.path = sys.path[1:]' \
               >> swift/utils/build-script; \
             chmod +x swift/utils/build-script"

# embedded buildSwiftOnArm

ENV REL=3.1.1 \
    INSTALL_DIR=/swiftsrc/install \
    PACKAGE=/swiftsrc/swift-3.1.1.tgz \
    BRANCH=swift-3.1.1-RELEASE \
    SWIFT_SOURCE_ROOT=/swiftsrc

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


# This is all wrong :-) Well, kinda. Building Swift in Docker is useful to
# reuse build steps in a clean way and not clutter the host with patched
# sources and such.
# But it would probably be better (and faster) to just run a script instead
# of building images.
#
# Hence the stuff below doesn't make sense. To pull out the built binary,
# you need to run a container with the image built by this dockerfile.

#VOLUME /package

# takes ~4mins on RPi3, ~122MB (BZip2 takes ~8mins on RPi3, saves 12MB)
#RUN tar zcf "/package/swift-3.1.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *
# tar zcf "/package/swift-3.1.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *

RUN bash

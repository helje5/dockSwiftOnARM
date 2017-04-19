# Dockerfile
#
# https://github.com/uraimo/buildSwiftOnARM.git
#
# TBD: I guess this shouldn't actually be a container but rather a
#      script which runs withing a plain ioft/armhf-ubuntu?!
#      (or maybe a /ubuntu-buildenv to save the APT setup)

FROM ioft/armhf-ubuntu:16.04

VOLUME /package
ARG SWIFT_VERSION=3.1
ENV SWIFT_RELEASE_TAG=swift-$SWIFT_VERSION-RELEASE

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# https://www.uraimo.com/2016/12/30/Swift-3-0-2-for-raspberrypi-zero-1-2-3/
# python3 required for test
RUN apt-get install -y \
  patch git     \
  libedit2      \
  libpython2.7 curl libxml2 \
  python3       \
  \
  cmake ninja-build clang-3.8 python uuid-dev libicu-dev                \
  icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev        \
  swig libpython-dev libncurses5-dev pkg-config libblocksruntime-dev    \
  libcurl4-openssl-dev autoconf libtool systemtap-sdt-dev libkqueue-dev \
  automake make m4 \
  \
  lsb-release
  
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 100


# Checkout Swift sources

RUN mkdir /swiftsrc
WORKDIR /swiftsrc

RUN git clone https://github.com/apple/swift
RUN ./swift/utils/update-checkout --clone

# https://github.com/uraimo/buildSwiftOnARM/blob/master/checkoutRelease.sh
RUN find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Cleaning '{}';cd '{}'; git reset --hard HEAD" \;
RUN find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Updating '{}';cd '{}'; git pull; git fetch --tags" \;
RUN find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Switching '{}' to ${SWIFT_RELEASE_TAG};cd '{}'; git checkout ${SWIFT_RELEASE_TAG}" \;


# Apply Patches from buildSwiftOnARM

RUN bash -c 'git clone https://github.com/uraimo/buildSwiftOnARM.git; \
             cd buildSwiftOnARM; \
             git archive -9 --format tgz master -o ../buildSwiftOnARM-$SWIFT_VERSION.tgz; \
             cd ..; \
             rm -rf buildSwiftOnARM; \
             cd /swiftsrc; \
             tar zxf ../buildSwiftOnARM-$SWIFT_VERSION.tgz; \
             rm ../buildSwiftOnARM-$SWIFT_VERSION.tgz'

WORKDIR /swiftsrc

RUN bash -c "for DIR in *; do \
               if test -d \"\${DIR}\"; then \
                 if test -d \"\${DIR}.diffs\"; then \
                   echo \"Applying patches to \${DIR}\" ; \
                   cd \"\${DIR}\"; \
                   patch -l -p1 < ../\${DIR}.diffs/*.diff; \
                   cd ..; \
                 fi; \
               fi; \
             done"


# Patch build.sh and run it

ENV SWIFT_SOURCE_ROOT /swiftsrc

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

RUN ./build.sh

# the results will be in
#   /swiftsrc/install/usr/[bin|include|lib|libexec|local|share]


WORKDIR /swiftsrc/install/usr/

# takes ~4mins on RPi3, ~122MB (BZip2 takes ~8mins on RPi3, saves 12MB)
RUN tar zcf "/package/swift-$SWIFT_VERSION-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *

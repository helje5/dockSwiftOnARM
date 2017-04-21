# Dockerfile
#
# docker run --privileged=true -i --tty --rm helje5/rpi-swift-dev:3.1.0
#
FROM helje5/rpi-swift:3.1.0

ARG MOD_SWIFT_VERSION=0.7.6
ARG CLANG_VERSION=3.8

# rpi-swift sets it to swift
USER root

ENV DEBIAN_FRONTEND noninteractive

# rpi-swift is installing stuff into site-packages, need to move them away
RUN mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/site-packages.swift
RUN apt-get install -y python2.7-minimal
RUN mv /usr/lib/python2.7/site-packages.swift/* /usr/local/lib/python2.7/dist-packages/
RUN rmdir /usr/lib/python2.7/site-packages.swift

RUN apt-get install -y python

RUN apt-get install -y clang-$CLANG_VERSION libc6-dev

RUN apt-get install -y \
  libicu-dev      \
  autoconf libtool pkg-config \
  libblocksruntime-dev \
  libkqueue-dev \
  libpthread-workqueue-dev \
  systemtap-sdt-dev \
  libbsd-dev libbsd0 \
  curl libcurl4-openssl-dev \
  libedit-dev \
  libxml2

RUN update-alternatives --quiet --install /usr/bin/clang   clang   /usr/bin/clang-$CLANG_VERSION   100
RUN update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-$CLANG_VERSION 100


RUN apt-get install -y wget curl \
       autoconf libtool pkg-config \
       apache2 apache2-dev

# dirty hack to get Swift module for APR working on Linux
# (Note: I've found a better way, stay tuned.)
RUN bash -c "\
    head -n -6 /usr/include/apr-1.0/apr.h \
    | sed 's/typedef  off64_t/typedef  off_t/' > /tmp/zz-apr.h; \
    echo ''                              >> /tmp/zz-apr.h; \
    echo '// mod_swift build hack'       >> /tmp/zz-apr.h; \
    echo 'typedef int pid_t;'            >> /tmp/zz-apr.h; \
    tail -n 6 /usr/include/apr-1.0/apr.h >> /tmp/zz-apr.h; \
    mv /usr/include/apr-1.0/apr.h /usr/include/apr-1.0/apr-original.h; \
    mv /tmp/zz-apr.h /usr/include/apr-1.0/apr.h"


USER swift

RUN bash -c "curl -L https://github.com/AlwaysRightInstitute/mod_swift/archive/$MOD_SWIFT_VERSION.tar.gz | tar zx"

WORKDIR /home/swift/mod_swift-$MOD_SWIFT_VERSION

RUN make all

CMD LD_LIBRARY_PATH="$PWD/.libs:$LD_LIBRARY_PATH" \
    EXPRESS_VIEWS=mods_expressdemo/views apache2 \
    -X -d $PWD -f apache-ubuntu.conf

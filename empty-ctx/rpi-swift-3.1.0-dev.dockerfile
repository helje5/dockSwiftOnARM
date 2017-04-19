# Dockerfile
#
# docker run --privileged=true -i --tty --rm helje5/rpi-swift-dev:3.1.0
#
FROM helje5/rpi-swift:3.1.0

ENV DEBIAN_FRONTEND noninteractive

ARG CLANG_VERSION=3.8

RUN apt-get install -y apt-utils
RUN apt-get install -y vim emacs make
RUN apt-get install -y git libicu55 libedit2

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
  libxml2 \
  wget

RUN update-alternatives --quiet --install /usr/bin/clang   clang   /usr/bin/clang-$CLANG_VERSION   100
RUN update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-$CLANG_VERSION 100

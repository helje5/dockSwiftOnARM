# Dockerfile
#
# An RPI Ubuntu environment for building Swift itself.
#
FROM ioft/armhf-ubuntu:16.04

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

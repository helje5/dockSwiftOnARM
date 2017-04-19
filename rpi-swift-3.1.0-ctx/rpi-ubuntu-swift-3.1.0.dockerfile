# Dockerfile
#
# docker run --privileged=true -i --tty --rm helje5/rpi-swift:3.1.0
# 

FROM ioft/armhf-ubuntu:16.04

ARG TARBALL=swift-3.1-armv7l-ubuntu-16.04.tar.gz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Funny: libcurl3 provies libcurl.so.4 :-)
RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu55 \
  sudo

ADD $TARBALL /usr/

RUN useradd --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

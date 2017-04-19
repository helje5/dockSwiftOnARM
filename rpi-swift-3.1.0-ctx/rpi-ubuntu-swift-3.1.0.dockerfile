# Dockerfile
#
FROM ioft/armhf-ubuntu:16.04

ARG TARBALL=swift-3.1-armv7l-ubuntu-16.04.tar.gz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 curl libxml2 libicu52

ADD $TARBALL /usr/

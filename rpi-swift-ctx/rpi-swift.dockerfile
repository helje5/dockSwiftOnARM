# Dockerfile
#
FROM resin/rpi-raspbian

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 curl libxml2

ADD swift-3.0.2-RPi23-RaspbianNov16.tgz /

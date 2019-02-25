FROM ioft/armhf-ubuntu:16.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL_URL=https://www.dropbox.com/s/qnf7p988lp46mlq/swift-4.2.2-RPi23-Ubuntu1604.tgz?dl=1
ARG TARBALL_FILE=swift-4.2.2-RPi23-Ubuntu1604.tgz

ENV DEBIAN_FRONTEND noninteractive

# Maybe libpython3.5 makes libpython2.7 obsolete?
RUN apt-get update && apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3-nss libxml2 libicu55 \
  libc6-dev \
  libatomic1    \
  libpython3.5 \
  clang \
  curl \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Uraimo's tarball starts at /
RUN curl -L -o $TARBALL_FILE $TARBALL_URL && tar -xvzf $TARBALL_FILE -C / && rm $TARBALL_FILE

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

# Dockerfile
#
FROM arm64v8/ubuntu:18.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL=swift-5.0-aarch64-DEV-18.04_2018-12-26.tar.gz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu60 \
  libc6-dev	\
  libatomic1	\
  libpython3.5 \
  libcurl3-nss


# tarball starts at /
ADD $TARBALL /

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

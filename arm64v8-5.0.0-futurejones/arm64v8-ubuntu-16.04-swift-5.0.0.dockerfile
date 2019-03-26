# Dockerfile
#
FROM arm64v8/ubuntu:16.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL=swift-5.0-aarch64-RELEASE-Ubuntu-16.04_2019-03-26.tar.gz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

# Funny: libcurl3 provies libcurl.so.4 :-)
# Maybe libpython3.5 makes libpython2.7 obsolete?
RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu55 \
  libc6-dev     \
  libatomic1    \
  libpython3.5  \
  curl
# curl seems necessary to grab the right lib, didn't research which one
# it is :-) /usr/lib/aarch64-linux-gnu/libcurl-* looks the same!

# tarball starts at /
ADD $TARBALL /

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

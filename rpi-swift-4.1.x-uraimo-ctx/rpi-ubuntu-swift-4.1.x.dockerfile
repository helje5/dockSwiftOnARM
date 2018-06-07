# Dockerfile
#
# First download the prebuild binaries (~170MB), does NOT contain SPM!:
#
#   curl -L -o swift-4.1.alpha1-armv7l-ubuntu16.04.tar.gz https://www.dropbox.com/s/403lkj84w0ifcye/raspi-swift-4.1-branch_nospm.tgz?dl=1
#
# docker run -i --tty --rm helje5/rpi-swift:4.1.alpha1
# 
FROM ioft/armhf-ubuntu:16.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL=swift-4.1.alpha1-armv7l-ubuntu16.04.tar.gz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Funny: libcurl3 provies libcurl.so.4 :-)
# Maybe libpython3.5 makes libpython2.7 obsolete?
RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu55 \
  libc6-dev	\
  libatomic1	\
  libpython3.5

# Uraimo's tarball starts at /
ADD $TARBALL /

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift


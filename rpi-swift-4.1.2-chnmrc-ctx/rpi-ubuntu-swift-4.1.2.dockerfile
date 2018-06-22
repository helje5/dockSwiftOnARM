# Dockerfile
#
# First download the prebuild binaries (~170MB), does NOT contain SPM!:
#
#   curl -o swift-4.1.2-RELEASE-ARMv7-chnmrc-2018-06-19.tgz http://mchini.com/swift/swift-4.1.2-RELEASE-ARMv7.tgz
#   curl -L -o swift-4.1-RELEASE-ARMV7-GLIBC2.23-chnmrc-2018-06-06.tgz https://www.dropbox.com/s/yauj3tyyh90cl05/swift-4.1-release-NOSPM-ARMV7-ubuntu-16.04-chnmrc.tgz?dl=1
#
# docker run -i --tty --rm helje5/rpi-swift:4.1.0
# 
FROM ioft/armhf-ubuntu:16.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL=swift-4.1.2-RELEASE-ARMv7-chnmrc-2018-06-19.tgz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

# Funny: libcurl3 provies libcurl.so.4 :-)
# Maybe libpython3.5 makes libpython2.7 obsolete?
# libcurl3-nss is required by latest chnmrc drop
RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu55 \
  libc6-dev	\
  libatomic1	\
  libpython3.5 \
  libcurl3-nss


# Chnmrc's tarball starts at /
ADD $TARBALL /

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

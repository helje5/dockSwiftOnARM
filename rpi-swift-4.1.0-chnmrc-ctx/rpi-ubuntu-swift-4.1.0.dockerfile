# Dockerfile
#
# First download the prebuild binaries (~170MB), does NOT contain SPM!:
#
#   curl -L -o swift-4.1-release-NOSPM-ARMV7-ubuntu-16.04-chnmrc.tgz https://www.dropbox.com/s/yauj3tyyh90cl05/swift-4.1-release-NOSPM-ARMV7-ubuntu-16.04-chnmrc.tgz?dl=1
#
# docker run -i --tty --rm helje5/rpi-swift:4.1.0
# 
FROM ioft/armhf-ubuntu:16.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL=swift-4.1-release-NOSPM-ARMV7-ubuntu-16.04-chnmrc.tgz

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade

# Funny: libcurl3 provies libcurl.so.4 :-)
# Maybe libpython3.5 makes libpython2.7 obsolete?
RUN apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu55 \
  libc6-dev	\
  libatomic1	\
  libpython3.5

# Chnmrc's tarball starts at /
ADD $TARBALL /

COPY dispatch-module.modulemap /usr/lib/swift/dispatch/
RUN bash -c "ln -sf /usr/lib/swift/dispatch/dispatch-module.modulemap \
                    /usr/lib/swift/dispatch/module.modulemap"

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

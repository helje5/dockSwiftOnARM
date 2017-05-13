# Dockerfile
#
# docker run --i --tty --rm helje5/swift-dev:3.1.0
#
# This is an x86_64 image for Swift w/ Emacs and such installed.
#
# To build:
#
#	  docker build -t helje5/swift-dev:latest -t helje5/swift-dev:3.1.0 \
#		       -f empty-ctx/swift-3.1.0-dev.dockerfile \
#		       empty-ctx
# 
FROM swift:3.1.0

LABEL maintainer "Helge Heß <me@helgehess.eu>"

USER root

ARG CLANG_VERSION=3.8

# b0rked in the official image
RUN chmod -R o+r /usr/lib/swift/CoreFoundation

# ldconfig not setup in official image
RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  apt-utils vim emacs make git libicu55 libedit2 \
  libicu-dev  \
  autoconf libtool pkg-config \
  curl libcurl4-openssl-dev \
  libedit-dev \
  libxml2 \
  wget sudo gosu \
  clang-$CLANG_VERSION libc6-dev libxml2-dev bison lsb-release

RUN bash -c "update-alternatives --quiet --install /usr/bin/clang \
               clang   /usr/bin/clang-$CLANG_VERSION   100;\
             update-alternatives --quiet --install /usr/bin/clang++ \
               clang++ /usr/bin/clang++-$CLANG_VERSION 100"

# setup sudo # TODO: sounds like we are supposed to use gosu instead

RUN bash -c "\
  useradd --groups sudo -ms /bin/bash swift; \
  echo 'swift ALL=(ALL:ALL) ALL' > /etc/sudoers.d/swift; \
  chmod 0440 /etc/sudoers.d/swift; \
  echo 'swift:swift' | chpasswd \
"

USER swift
WORKDIR /home/swift

RUN bash -c "\
  mkdir -p /home/swift/.emacs.d/lisp; \
  curl -L -o /home/swift/.emacs.d/lisp/swift-mode.el https://raw.githubusercontent.com/iamleeg/swift-mode/master/swift-mode.el; \
  echo \"(add-to-list 'load-path \\\"~/.emacs.d/lisp/\\\")\" >> .emacs; \
  echo \"(require 'swift-mode)\" >> .emacs \
"

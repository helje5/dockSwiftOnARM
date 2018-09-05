# Dockerfile
#
#   docker build -t helje5/arm64v8-swift-dev:4.1.0 \
#     -f empty-ctx/arm64v8-swift-4.1.0-dev.dockerfile \
#     ./empty-ctx
#   docker run -i --tty --name "swift-dev" --rm helje5/arm64v8-swift-dev:4.1.0
#
FROM helje5/arm64v8-swift:4.1.1

LABEL maintainer "Helge Heß <me@helgehess.eu>"

# rpi-swift sets it to swift
USER root

ENV DEBIAN_FRONTEND noninteractive

ARG CLANG_VERSION=3.8

RUN apt-get install -y apt-utils \
                       vim emacs make \
                       git libicu55 libedit2

# rpi-swift is installing stuff into site-packages, need to move them away
RUN bash -c "\
  mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/site-packages.swift; \
  apt-get install -y python2.7-minimal; \
  mv /usr/lib/python2.7/site-packages.swift/* \
     /usr/local/lib/python2.7/dist-packages/; \
  rmdir /usr/lib/python2.7/site-packages.swift \
"

RUN apt-get install -y \
  python                      \
  \
  clang-$CLANG_VERSION libxml2-dev bison lsb-release gdb \
  \
  libicu-dev                  \
  autoconf libtool pkg-config \
  libblocksruntime-dev        \
  libpthread-workqueue-dev    \
  systemtap-sdt-dev           \
  libbsd-dev libbsd0          \
  curl libcurl4-openssl-dev   \
  libedit-dev                 \
  libxml2                     \
  wget sudo gosu              \
  zlib1g-dev                  \
  libsqlite3-dev              \
  telnet netcat               \
  inetutils-ping dialog       \
  nfs-common

RUN bash -c "update-alternatives --quiet --install /usr/bin/clang \
               clang   /usr/bin/clang-$CLANG_VERSION   100;\
             update-alternatives --quiet --install /usr/bin/clang++ \
               clang++ /usr/bin/clang++-$CLANG_VERSION 100"

# setup sudo # TODO: sounds like we are supposed to use gosu instead

RUN bash -c "\
  adduser swift sudo; \
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
  echo \"(require 'swift-mode)\"; >> .emacs \
  echo \"(setq-default indent-tabs-mode nil)\" >> .emacs \
"

# Dockerfile
#
FROM swift:6.1

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

# Maybe libpython3.5 makes libpython2.7 obsolete?
#libpython2.7
#libpython3.5
RUN apt-get install -y \
  git           \
  libedit2      \
  libcurl4 libxml2 \
  libc6-dev     \
  libatomic1    \
  curl          \
  libcrypt-dev  \
  vim           \
  emacs

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

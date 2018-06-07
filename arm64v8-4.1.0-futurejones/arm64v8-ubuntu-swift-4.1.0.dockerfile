# Dockerfile
#
#   docker build -t helje5/arm64v8-swift:4.1.0 \
#     -f arm64v8-4.1.0-futurejones/arm64v8-ubuntu-swift-4.1.0.dockerfile \
#     ./empty-ctx
#   docker run -i --tty --rm helje5/arm64v8-swift:4.1.0
# 
FROM arm64v8/ubuntu:16.04

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG SWIFTPKG=https://packagecloud.io/swift-arm/debian/packages/debian/stretch/swift4_4.1_arm64.deb

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

RUN bash -c "curl -s https://packagecloud.io/install/repositories/swift-arm/debian/script.deb.sh | bash"

RUN apt-get install -y swift4

RUN bash -c "echo '/usr/lib/swift/linux' > /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/clang/lib/linux' >> /etc/ld.so.conf.d/swift.conf;\
             echo '/usr/lib/swift/pm' >> /etc/ld.so.conf.d/swift.conf;\
             ldconfig"

RUN useradd -u 501 --create-home --shell /bin/bash swift

USER swift
WORKDIR /home/swift

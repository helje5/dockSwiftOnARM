FROM balenalib/raspberry-pi-debian:stretch

LABEL maintainer "Helge Heß <me@helgehess.eu>"

ARG TARBALL_URL=https://www.dropbox.com/s/08aem3xndyfafdi/swift-4.2.2-RPi01-RaspbianStretch.tgz?dl=1
ARG TARBALL_FILE=swift-4.2.2-RPi01-RaspbianStretch.tgz

ENV DEBIAN_FRONTEND noninteractive

# Funny: libcurl3 provies libcurl.so.4 :-)
# Maybe libpython3.5 makes libpython2.7 obsolete?
RUN apt-get update && apt-get install -y \
  git           \
  libedit2      \
  libpython2.7 libcurl3 libxml2 libicu-dev \
  libc6-dev \
  libatomic1  \
  libpython3.5 \
  clang \
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

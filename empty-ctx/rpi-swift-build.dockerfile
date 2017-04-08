# Dockerfile
#
# https://github.com/uraimo/buildSwiftOnARM.git

FROM helje5/rpi-raspbian-swift-build302-env

ENV DEBIAN_FRONTEND noninteractive

# swiftsrc is in /swiftsrc

RUN bash -c 'git clone https://github.com/uraimo/buildSwiftOnARM.git; \
             cd buildSwiftOnARM; \
             git archive -9 --format tgz tags/3.0.2 -o ../buildSwiftOnARM-3.0.2.tgz; \
             cd ..; \
             rm -rf buildSwiftOnARM; \
             cd /swiftsrc; \
             tar zxf ../buildSwiftOnARM-3.0.2.tgz; \
             rm ../buildSwiftOnARM-3.0.2.tgz'

WORKDIR /swiftsrc

RUN find . -maxdepth 1 -type d \( ! -name . \) \
      -exec bash -c "echo Applying patches to '{}';cd '{}'; patch -p1 < ../'{}'.diffs/*.diff" \;

RUN ./build.sh

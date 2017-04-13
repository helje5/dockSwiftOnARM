# Dockerfile
#
# https://github.com/uraimo/buildSwiftOnARM.git
#
# docker run --rm --interactive --tty helje5/rpi-swift-build

FROM helje5/rpi-ubuntu-swift-build31-env

ENV DEBIAN_FRONTEND noninteractive

# swiftsrc is in /swiftsrc

RUN bash -c 'git clone https://github.com/uraimo/buildSwiftOnARM.git; \
             cd buildSwiftOnARM; \
             git archive -9 --format tgz master -o ../buildSwiftOnARM-3.1.tgz; \
             cd ..; \
             rm -rf buildSwiftOnARM; \
             cd /swiftsrc; \
             tar zxf ../buildSwiftOnARM-3.1.tgz; \
             rm ../buildSwiftOnARM-3.1.tgz'

WORKDIR /swiftsrc

RUN bash -c "for DIR in *; do \
               if test -d \"\${DIR}\"; then \
                 if test -d \"\${DIR}.diffs\"; then \
                   echo \"Applying patches to \${DIR}\" ; \
                   cd \"\${DIR}\"; \
                   patch -p1 < ../\${DIR}.diffs/*.diff; \
                   cd ..; \
                 fi; \
               fi; \
             done"

ENV SWIFT_SOURCE_ROOT /swiftsrc

RUN ./build.sh

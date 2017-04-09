# Dockerfile
#
# https://github.com/uraimo/buildSwiftOnARM.git
#
# docker run --rm --interactive --tty helje5/rpi-swift-build

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

#RUN mkdir -p /swiftsrc/install/usr/lib/swift

ENV PYTHONPATH /usr/lib/python2.7:/usr/lib/python2.7/plat-arm-linux-gnueabihf:/usr/lib/python2.7/lib-tk:/usr/lib/python2.7/lib-old:/usr/lib/python2.7/lib-dynload:/usr/local/lib/python2.7/dist-packages:/usr/lib/python2.7/dist-packages:/swiftsrc/swift/utils/swift_build_support:/swiftsrc/swift/utils

# this fails because the script patches the PYTHONPATH so that
# swiftsrc/swift/utils is before swiftsrc/swift/utils/swift_build_support
# (and hence picks up the duplicate swift_build_support directory)
# sys.path.append(os.path.dirname(__file__)) ...

# TODO make this a patch
COPY build-script /swiftsrc/swift/utils/build-script 

RUN ./build.sh

# Dockerfile
#
# https://github.com/uraimo/buildSwiftOnARM.git
#
# docker run --rm --interactive --tty helje5/rpi-swift-build

FROM helje5/rpi-ubuntu-swift-build311-env

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
                   patch -l -p1 < ../\${DIR}.diffs/*.diff; \
                   cd ..; \
                 fi; \
               fi; \
             done"

ENV SWIFT_SOURCE_ROOT /swiftsrc

# this fails because the script patches the PYTHONPATH so that
# swiftsrc/swift/utils is before swiftsrc/swift/utils/swift_build_support
# (and hence picks up the duplicate swift_build_support directory)
# sys.path.append(os.path.dirname(__file__)) ...
RUN bash -c "mv swift/utils/build-script swift/utils/build-script.orig;   \
             cat swift/utils/build-script.orig \
             | sed '/import sys/a sys.path.append(os.path.join(os.path.dirname(__file__), \"swift_build_support\"))' \
             | sed '/import sys/a sys.path = sys.path[1:]' \
               >> swift/utils/build-script; \
             chmod +x swift/utils/build-script"

RUN ./build.sh

# the results will be in
#   /swiftsrc/install/usr/[bin|include|lib|libexec|local|share]

WORKDIR /swiftsrc/install/usr/

RUN apt-get install -y lsb-release

VOLUME /package

# takes ~4mins on RPi3, ~122MB (BZip2 takes ~8mins on RPi3, saves 12MB)
RUN tar zcf "/package/swift-3.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *

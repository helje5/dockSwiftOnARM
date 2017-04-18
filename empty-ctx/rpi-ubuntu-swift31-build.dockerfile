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

# Workaround for the failing 5537ff94b5b636f451c046429cbb35e1e5b0908f.diff
# patch on swift-corelibs-foundation:
#     Applying patches to swift-corelibs-foundation
#     patching file CoreFoundation/Base.subproj/SwiftRuntime/CoreFoundation.h
#     patching file CoreFoundation/URL.subproj/CFURLSessionInterface.h
#     patching file build.py
#     Hunk #1 FAILED at 81.
# https://github.com/uraimo/buildSwiftOnARM/issues/1
# -if triple.endswith("-linux-gnu") or triple == "armv7-none-linux-androideabi":
# +if triple.find("linux") != -1:
RUN bash -c "mv swift-corelibs-foundation/build.py swift-corelibs-foundation/build.py.dockorig; \
             cat swift-corelibs-foundation/build.py.dockorig \
             | sed 's/triple.endswith(\"-linux-gnu\")/triple.find(\"linux\") != -1/g' \
             > swift-corelibs-foundation/build.py"

RUN ./build.sh

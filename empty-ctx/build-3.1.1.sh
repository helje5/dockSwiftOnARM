#!/bin/bash

apt-get update
apt-get install -y \
  patch git       \
  libedit2        \
  libpython2.7    \
  curl libxml2    \
  python3         \
  cmake ninja-build clang-3.8 python uuid-dev libicu-dev \
  icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev \
  swig libpython-dev libncurses5-dev pkg-config libblocksruntime-dev \
  libcurl4-openssl-dev autoconf libtool systemtap-sdt-dev \
  automake make m4 \
  lsb-release

update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 100

# grab Swift
git clone https://github.com/helje5/dockSwiftOnARM.git
cd dockSwiftOnARM
./grab-swift.sh 
./make-swift-branch-tarball.sh swift-checkout swift-3.1.1-RELEASE

mv swift-checkout /swiftsrc
cd /swiftsrc/

# patches
curl -L -o swift-llvm-fdfc8ed7.diff \
     https://github.com/swift-arm/swift-llvm/commit/95581a28b69cc7ea811055891b499576fdfc8ed7.diff
curl -L -o swift-corelibs-libdispatch-233.diff \
     https://github.com/apple/swift-corelibs-libdispatch/pull/233.diff
cd swift-corelibs-libdispatch && \
   patch -l -p1 < ../swift-corelibs-libdispatch-233.diff; cd ..
cd llvm && patch -l -p1 < ../swift-llvm-fdfc8ed7.diff; cd ..

# patch build script
mv swift/utils/build-script swift/utils/build-script.orig
cat swift/utils/build-script.orig \
  | sed '/import sys/a sys.path.append(os.path.join(os.path.dirname(__file__), \"swift_build_support\"))' 
  | sed '/import sys/a sys.path = sys.path[1:]' >> swift/utils/build-script
chmod +x swift/utils/build-script

export REL=3.1.1
export INSTALL_DIR=$PWD/install
export PACKAGE=$PWD/swift-${REL}.tgz
export BRANCH=swift-3.1.1-RELEASE
export SWIFT_SOURCE_ROOT=/swiftsrc

./swift/utils/build-script --build-subdir buildbot_linux -R \
       --lldb --llbuild --xctest --swiftpm --foundation --libdispatch \
       -- --install-libdispatch --install-foundation --install-swift \
       --install-lldb --install-llbuild --install-xctest --install-swiftpm \
       --install-prefix=/usr \
       '--swift-install-components=autolink-driver;compiler;clang-builtin-headers;stdlib;swift-remote-mirror;sdk-overlay;dev' \
       --build-swift-static-stdlib --build-swift-static-sdk-overlay \
       --install-destdir=$INSTALL_DIR --installable-package=$PACKAGE


echo "+ Fixing up the install package for ARM"

cp -R swift-corelibs-libdispatch/dispatch/ ${INSTALL_DIR}/usr/lib/swift
cp ./build/buildbot_linux/libdispatch-linux-armv7/src/swift/Dispatch.swiftdoc \
     ${INSTALL_DIR}/usr/lib/swift/linux/armv7/
cp ./build/buildbot_linux/libdispatch-linux-armv7/src/swift/Dispatch.swiftmodule \
     ${INSTALL_DIR}/usr/lib/swift/linux/armv7/
cp ./build/buildbot_linux/libdispatch-linux-armv7/src/libdispatch.la \
     ${INSTALL_DIR}/usr/lib/swift/linux/
cp ./build/buildbot_linux/libdispatch-linux-armv7/src/.libs/libdispatch.so \
     ${INSTALL_DIR}/usr/lib/swift/linux
mkdir -p ${INSTALL_DIR}/usr/lib/swift/os
cp swift-corelibs-libdispatch/os/linux_base.h ${INSTALL_DIR}/usr/lib/swift/os
cp swift-corelibs-libdispatch/os/object.h ${INSTALL_DIR}/usr/lib/swift/os


echo "+ Retar installation package"

tar -C ${INSTALL_DIR} -czf ${PACKAGE} .


#tar zcf "/package/swift-3.1-$(uname -m)-$(lsb_release -i -s | tr A-Z a-z)-$(lsb_release -r -s).tar.gz" *

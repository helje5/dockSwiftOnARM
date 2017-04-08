#!/bin/bash

#  ./make-swift-branch-tarball.sh swift-checkout swift-3.1-RELEASE
#  ./make-swift-branch-tarball.sh swift-checkout swift-3.0.2-RELEASE

OWN_DIR="`pwd`"
SWIFT_DIR="$1"
BRANCH="$2" # swift-3.1-RELEASE

cd "${SWIFT_DIR}"

# https://github.com/uraimo/buildSwiftOnARM/blob/master/checkoutRelease.sh

find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Cleaning '{}';cd '{}'; git reset --hard HEAD" \;
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Updating '{}';cd '{}'; git pull; git fetch --tags" \;
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Switching '{}' to ${BRANCH};cd '{}'; git checkout ${BRANCH}" \;

# RPi
#find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "echo Applying patches to '{}';cd '{}'; patch -p1 < ../'{}'.diffs/*.diff" \;

tar zcf "${OWN_DIR}/$BRANCH.tgz" .

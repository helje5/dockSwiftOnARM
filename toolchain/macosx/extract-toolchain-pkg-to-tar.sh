#!/bin/bash

#  $HOME/Downloads/swift-3.1-RELEASE-osx.pkg

function usage() {
  echo >&2 "Usage: $0 A.pkg A.tar.gz"
}

function realpath() {
    if [[ "${1:0:1}" = / ]]; then
        echo "$1"
    else
        (
        cd "$(dirname "$1")"
        echo "$(pwd)/$(basename "$1")"
        )
    fi
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

XARFILE="$(realpath "$1")"
TARBALL="$(realpath "$2")"
echo "XAR:  $XARFILE"
echo "Dest: $TARBALL"

tmp=$(mktemp -d /tmp/.unpack_pkg_XXXXXX)
(
  cd "$tmp"
  xar -xf "$XARFILE"
)
  
tartmp=$(mktemp -d /tmp/.unpack_pkg_tar_XXXXXX)
(
  cd "$tartmp"
  cat "$tmp"/*.pkg/Payload | gunzip -dc | cpio -i
  tar zc \
    --exclude sourcekitd.framework \
    --exclude appletvos \
    --exclude appletvsimulator \
    --exclude iphoneos \
    --exclude iphonesimulator \
    --exclude watchos \
    --exclude watchsimulator \
    --exclude AppleTVSimulator.platform \
    --exclude iPhoneSimulator.platform \
    --file="$TARBALL" *
)

rm -rf "$tmp" "$tartmp"

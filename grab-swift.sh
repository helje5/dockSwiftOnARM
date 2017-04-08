#!/bin/bash

DATEMARK="`date "+%Y%m%dT%H%M%S"`"
TARBALL="swift-checkout-${DATEMARK}.tar.bz2"

# this is huge and takes a long time!
#helge@ZeeMBP raspi (master)$ ls -ladh swift-checkout.tar.bz2 
#-rw-r--r--  1 helge  staff   943M Apr  8 13:16 swift-checkout.tar.bz2

mkdir -p swift-checkout
cd swift-checkout
git clone https://github.com/apple/swift
./swift/utils/update-checkout --clone
cd ..
tar jcf ${TARBALL} swift-checkout

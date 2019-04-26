#!/bin/sh
for i in `ls $DSTROOT/Library/Developer/Destinations`
do 
pushd $DSTROOT/Library/Developer/Destinations 
cat $i | sed s:\$INSTALL_ROOT:$DSTROOT:g > $i.resolved
mv $i $i.orig
mv $i.resolved $i
rm $i.orig
popd
done


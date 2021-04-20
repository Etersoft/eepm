#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

for i in lib/python3 lib/python2.7 ; do
    t=$i
    if [ -d $BUILDROOT/usr/$i/dist-packages ] ; then
        mv -v $BUILDROOT/usr/$i/dist-packages $BUILDROOT/usr/$t/site-packages
        subst "s|/usr/$i/dist-packages|/usr/$t/site-packages|" $SPEC
    fi
done

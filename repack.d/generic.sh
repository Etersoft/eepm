#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

flag_python3=''

for i in lib/python3 lib/python2.7 ; do
    t=$i
    if [ -d $BUILDROOT/usr/$i/dist-packages ] ; then
        mv -v $BUILDROOT/usr/$i/dist-packages $BUILDROOT/usr/$t/site-packages
        subst "s|/usr/$i/dist-packages|/usr/$t/site-packages|" $SPEC
    fi
done

for i in $BUILDROOT/usr/bin/* ; do
    [ -f "$i" ] || continue
    grep -q '^#!/usr/bin/python' $i && flag_python3=1
    subst 's|^#!/usr/bin/python$|#!/usr/bin/python3|' $i
done

# check for .py scripts
find $BUILDROOT -name "*.py" | grep -q "\.py$" && flag_python3=1

if [ -n "$flag_python3" ] ; then
    epm install --skip-installed rpm-build-python3
fi

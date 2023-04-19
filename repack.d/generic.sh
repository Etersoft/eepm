#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"

# firstly, pack $PRODUCTDIR if used
. $(dirname $0)/common.sh

flag_python3=''

for i in lib/python3 lib/python2.7 ; do
    t=$i
    if [ -d $BUILDROOT/usr/$i/dist-packages ] ; then
        mv -v $BUILDROOT/usr/$i/dist-packages $BUILDROOT/usr/$t/site-packages
        subst "s|/usr/$i/dist-packages|/usr/$t/site-packages|" $SPEC
    fi
done

for i in $BUILDROOT/usr/bin/* ; do
    [ -L "$i" ] && continue
    [ -f "$i" ] || continue
    grep -Eq '^#!/usr/bin/python|^#!/usr/bin/env python' $i && flag_python3=1
    subst 's|^#!/usr/bin/python$|#!/usr/bin/python3|' $i
    subst 's|^#!/usr/bin/env python$|#!/usr/bin/env python3|' $i
done

# check for .py scripts
find $BUILDROOT -name "*.py" | grep -q "\.py$" && flag_python3=1
find $BUILDROOT -name "*.py" -exec subst '1{/python3/n};1i#!/usr/bin/python3' {} \;

if [ -n "$flag_python3" ] ; then
    if [ "$(epm print info -s)" = "alt" ] ; then
        epm install --skip-installed rpm-build-python3
    fi
fi

# hack:
# TODO: check for tarball, detect root dir
#echo $BUILDROOT | grep -q "tar.*tmpdir/" && move_to_opt /liteide

# Set high Epoche to override repository package
subst "s|^\(Name: .*\)$|# Override repository package\nEpoch: 100\n\1|g" $SPEC

[ -d $BUILDROOT/usr/lib/.build-id ] && remove_dir /usr/lib/.build-id || :

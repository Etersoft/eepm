#!/bin/bash

# TODO: use epm from the sources

fatal()
{
    exit 1
}

TDIR=~/epm-play-versions
EDIR=~/epm-errors
LDIR=~/epm-logs
mkdir -p $TDIR/ $EDIR/ $LDIR/

rm -f $EDIR/errors.txt

EPM=$(realpath $(dirname $0)/../bin/epm)

# install/update all
$EPM play --list-all --short | while read app ; do
    pkgname="$($EPM play --package-name $app </dev/null)"
    if $EPM play --verbose --auto $app </dev/null >$EDIR/$app 2>&1 ; then
        # if OK, move output
        mv -f $EDIR/$app $LDIR/$app
        $EPM play installed-version $app > $TDIR/$app 2>$EDIR/$pkgname </dev/null && rm -f $EDIR/$pkgname
        [ -s $TDIR/$app ] || echo "empty file $TDIR/$app" >>$EDIR/errors.txt
    #else
        # if not OK, keep old version file (try to avoid updating)
        # rm -f $TDIR/$app
    fi
done

cd $TDIR
[ -d .git ] || git init
git add *
git commit -m "updated"

cd $EDIR
[ -d .git ] || git init
git add *
git commit -m "updated"

cd $TMP
rm -rf tmp.* rpm-tmp.*

exit 0

#!/bin/sh

PKGNAME=atom
SUPPORTEDARCHES="x86_64"
PRODUCTALT="'' beta"
DESCRIPTION="The hackable text editor from the official site"

for i in $PRODUCTALT ; do
    [ "$i" = "''" ] && continue
    if [ "$2" = "$i" ] || epm installed $PKGNAME-$i ; then
        PKGNAME=$PKGNAME-$i
        break
    fi
done

. $(dirname $0)/common.sh

#arch=$(epm print info --distro-arch)
#pkgtype=$(epm print info -p)
arch=amd64
pkgtype=deb

notbeta=''
if [ "$PKGNAME" = "atom" ] ; then
    notbeta='-v'
fi

PKG=$(epm tool eget --list https://github.com/atom/atom/releases/ "atom-$arch.$pkgtype" | grep $notbeta -- "-beta" | head -n1) || fatal "Can't get package URL"

epm install "$PKG"

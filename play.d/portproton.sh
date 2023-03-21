#!/bin/sh

PKGNAME=portproton
SUPPORTEDARCHES="x86_64"
DESCRIPTION='PortProton (from the repository if the package is there, or from the official site)'

. $(dirname $0)/common.sh

res=0
if ! epm install portproton ; then
    PKGURL="https://github.com/Castro-Fidel/PortProton_dpkg/releases/download/portproton_1.0-2_amd64/portproton_1.0-2_amd64.deb"
    epm install $PKGURL
    res=$?
fi

#epm pack --install $PKGNAME https://github.com/Castro-Fidel/PortWINE/archive/refs/heads/master.tar.gz

epm play i586-fix

exit $res

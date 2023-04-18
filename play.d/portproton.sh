#!/bin/sh

PKGNAME=portproton
SUPPORTEDARCHES="x86_64"
DESCRIPTION='PortProton (from the repository if the package is there, or from the official site)'

. $(dirname $0)/common.sh

res=0
if ! epm install portproton ; then
    PKGURL="$(eget --list --latest https://github.com/Castro-Fidel/PortProton_dpkg/releases portproton_*amd64.deb)"
    epm install $PKGURL
    res=$?
fi


# TODO: get from  grep '^###Scripts version ' PortWINE/data_from_portwine/changelog_eng | head -n1
###Scripts version 2172###
#VERSION="$(epm tool eget -O- https://api.github.com/repos/Castro-Fidel/PortWINE/commits/HEAD | grep '"message": "Scripts version' | sed -e 's|.*Scripts version ||' -e 's|".*||' )"
#epm pack --install $PKGNAME https://github.com/Castro-Fidel/PortWINE/archive/refs/heads/master.tar.gz $VERSION

epm play i586-fix

exit $res

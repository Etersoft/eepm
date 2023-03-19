#!/bin/sh

PKGNAME=portproton
SUPPORTEDARCHES="x86_64"
DESCRIPTION='' #"PortProton from the official site"

. $(dirname $0)/common.sh

epm pack --install $PKGNAME https://github.com/Castro-Fidel/PortWINE/archive/refs/heads/master.tar.gz
res=$?

epm play i586-fix

exit $res

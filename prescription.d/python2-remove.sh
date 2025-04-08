#!/bin/sh

SUPPORTEDARCHES=''
DESCRIPTION="Remove all possible python2 packages"

. $(dirname $0)/common.sh

[ "$(epm print info -s)" = "alt" ] || { echo "Only ALTLinux is supported" ; exit 1 ; }

PACKAGES="$(epm qp python-module)"

[ -n "$PACKAGES" ] || { echo "All python2 packages are already removed" ; exit 0 ; }

epm remove $PACKAGES

epm remove python2-base

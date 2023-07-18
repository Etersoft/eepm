#!/bin/sh

[ "$1" != "--run" ] && echo "Remove all 32 bit packages from 64 bit system" && exit

. $(dirname $0)/common.sh

[ "$(epm print info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

case "$(epm print info -s)" in
    alt)
        epm --verbose --simulate remove $(epmqp "^i586-")
        ;;
    ubuntu|debian)
        epm --verbose --simulate remove $(epmqp "^i386-")
        ;;
    fedora|centos|redos|rhel)
        epm --verbose --simulate remove $(epmqp "\.i686$")
        ;;
    *)
        fatal "unsupported vendor $(epm print info -s)"
        ;;
esac

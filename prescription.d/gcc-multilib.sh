#!/bin/sh

[ "$1" != "--run" ] && echo "Remove all 32 bit packages from 64 bit system" && exit

. $(dirname $0)/common.sh

[ "$(epm print info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

case "$(epm print info -s)" in
    alt)
        epm assure gcc || exit
        #GCCVERSION=$(epm print version for package gcc)
        #epmi i586-gcc$GCCVERSION
        epmi $(epmq --short gcc{8,9,10,11,12,13,14,15,16,17} 2>/dev/null | sed -e 's|^gcc|i586-gcc|') i586-glibc-devel
        ;;
    ubuntu|debian)
        epm install gcc-multilib
        ;;
#    fedora|centos|redos|rhel)
#        ;;
    *)
        fatal "unsupported vendor $(epm print info -s)"
        ;;
esac

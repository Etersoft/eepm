#!/bin/sh

[ "$1" != "--run" ] && echo "Add 32 bit support on 64 bit system" && exit

. $(dirname $0)/common.sh

[ "$(epm print info -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1


vendor="$(epm print info -s)"
case "$vendor" in
    "alt")
        if epm --quiet repo list | grep -q "x86_64-i586 classic" ; then
            #[ -n "$verbose" ] && info "This system is ready to install 32bit packages"
            exit 0
        else
            epm repo add "$(epm --quiet repo list | grep "x86_64 classic" | sed -e 's|x86_64|x86_64-i586|')"
            epm update
        fi
        exit
        ;;
esac

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    "deb")
        if a= dpkg --print-foreign-architectures | grep -q "i386" ; then
            #[ -n "$verbose" ] && info "This system is ready to install 32bit packages"
            exit 0
        else
            a= dpkg --add-architecture i386
            epm update
        fi
        ;;
    *)
        info "Unsupported $(epm print info -e) system. Just skipping the operation."
        exit
        ;;
esac

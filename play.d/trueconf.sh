#!/bin/sh

PKGNAME=trueconf
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TrueConf client for Linux from the official site"

. $(dirname $0)/common.sh

epmopt=''
distrversion=$(epm print info -v)
case "$(epm print info -e)" in
    ALTLinux/p10|ALTLinux/Sisyphus)
        URL="https://mirror.trueconf.ru/altlinux/p10/x86_64/RPMS.non-free/trueconf-${VERSION}*.x86_64.rpm"
        # we need repack, they change files in a home dir
        epmopt='--direct --repack'
        ;;
    ALTLinux/p9)
        URL="https://mirror.trueconf.ru/altlinux/p9/x86_64/RPMS.non-free/trueconf-${VERSION}*.x86_64.rpm"
        epmopt='--direct --repack'
        ;;
    ALTLinux/p8)
        URL="https://mirror.trueconf.ru/altlinux/p8/x86_64/RPMS.non-free/trueconf-${VERSION}*.x86_64.rpm"
        epmopt='--direct --repack'
        ;;
    ALTLinux/c8.2)
        URL="https://mirror.trueconf.ru/altlinux/c8.2/x86_64/RPMS.non-free/trueconf-${VERSION}*.x86_64.rpm"
        epmopt='--direct --repack'
        ;;
    AstraLinuxCE/2.12*)
        URL="https://mirror.trueconf.ru/astra212/pool/non-free/t/trueconf/trueconf_${VERSION}*_amd64.deb"
        ;;
    AstraLinuxSE/1.6*)
        URL="https://mirror.trueconf.ru/astra16/pool/non-free/t/trueconf/trueconf_${VERSION}*_amd64.deb"
        ;;
    AstraLinuxSE/1.7*)
        URL="https://mirror.trueconf.ru/astra17/pool/non-free/t/trueconf/trueconf_${VERSION}*_amd64.deb"
        ;;
    Debian/*)
        URL="https://mirror.trueconf.ru/debian/pool/non-free/t/trueconf/trueconf_${VERSION}-*deb${distrversion}_amd64.deb"
        ;;
    Ubuntu/*)
        URL="https://mirror.trueconf.ru/ubuntu/pool/non-free/t/trueconf/trueconf_${VERSION}-*ubt${distrversion}_amd64.deb"
        ;;
    Fedora/*)
        URL="https://mirror.trueconf.ru/fedora/$distrversion/x86_64/release/trueconf-${VERSION}-*.x86_64.rpm"
        ;;
    RedOS/7.*)
        URL="https://mirror.trueconf.ru/redos/$distrversion/x86_64/release/trueconf-${VERSION}*.x86_64.rpm"
        ;;
    ROSA/2021.1)
        URL="https://mirror.trueconf.ru/rosa/$distrversion/x86_64/testing/trueconf-${VERSION}*.x86_64.rpm"
        ;;
    RELS/7.9)
        URL="https://mirror.trueconf.ru/rosa/$distrversion/x86_64/testing/trueconf-${VERSION}*.x86_64.rpm"
        ;;
    *)
        fatal "$(epm print info -e) is not supported"
esac

# --repack includes --noscripts
epm install $epmopt "$URL" || exit

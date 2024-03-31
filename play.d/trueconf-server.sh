#!/bin/sh

PKGNAME=trueconf-server
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="TrueConf server for Linux from the official site"
URL="https://trueconf.ru"

. $(dirname $0)/common.sh

warn_version_is_not_supported
#[ "$VERSION" = "*" ] && VERSION="[0-9]*"
# only one version in repo
VERSION="*"

distrversion=$(epm print info -v)
case "$(epm print info -e)" in
    ALTLinux/p10|ALTLinux/Sisyphus)
        PKGURL="https://mirror.trueconf.ru/altlinux/p10/x86_64/RPMS.non-free/trueconf-server-${VERSION}*.x86_64.rpm"
        ;;
    ALTLinux/p9)
        PKGURL="https://mirror.trueconf.ru/altlinux/p9/x86_64/RPMS.non-free/trueconf-${VERSION}*.x86_64.rpm"
        ;;
    AstraLinuxSE/1.7*)
        PKGURL="https://mirror.trueconf.ru/astra17/pool/non-free/t/trueconf-server/trueconf_server_${VERSION}*_amd64.deb"
        ;;
    RedOS/7.*)
        PKGURL="https://mirror.trueconf.ru/redos/$distrversion/x86_64/release/trueconf-server-${VERSION}*.x86_64.rpm"
        ;;
    *)
        fatal "$(epm print info -e) is not supported"
esac

# TODO: repack?
# --repack includes --noscripts
epm install "$PKGURL" || exit

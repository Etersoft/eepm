#!/bin/sh

PKGNAME=master-pdf-editor
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Master PDF Editor from the official site"

. $(dirname $0)/common.sh

repack=''
# Strict supported list
case $(epm print info -e) in
    AstraLinuxCE/*|Debian/*|Ubuntu/*)
        PKG="master-pdf-editor-5.8.70-qt5.x86_64.deb"
        ;;
    AstraLinuxSE/1.7*)
        PKG="master-pdf-editor-5.8.70-qt5_astra.x86_64.deb"
        ;;
    RedOS/*|AlterOS/*|ALTLinux/*|ALTServer/*)
        PKG="master-pdf-editor-5.8.70-qt5.x86_64.rpm"
        repack='--repack'
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac

URL="https://code-industry.ru/public/$PKG"

epm $repack install "$URL"

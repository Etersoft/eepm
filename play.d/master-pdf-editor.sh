#!/bin/sh

PKGNAME=master-pdf-editor
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Master PDF Editor from the official site"

. $(dirname $0)/common.sh

PKG=''
repack=''
# Strict supported list
case $(epm print info -e) in
    AstraLinuxCE/*|Debian/9|Ubuntu/20)
        PKG="master-pdf-editor-*-qt5.9.x86_64.deb"
        ;;
    AstraLinuxSE/1.7*|Debian/*|Ubuntu/*)
        PKG="master-pdf-editor-*-qt5.x86_64.deb"
        ;;
    RedOS/*|AlterOS/*|ALTLinux/*|ALTServer/*|MOC/*)
        PKG="master-pdf-editor-*-qt5.x86_64.rpm"
        repack='--repack'
        ;;
esac

if [ -z "$PKG" ] ; then
    case $(epm print info -p) in
        rpm)
            PKG="master-pdf-editor-*-qt5.x86_64.rpm"
            ;;
        *)
            PKG="master-pdf-editor-*-qt5.x86_64.deb"
            ;;
    esac
fi

PKGURL=$(epm tool eget --list --latest https://code-industry.ru/get-master-pdf-editor-for-linux/ $PKG)

epm $repack install "$PKGURL"

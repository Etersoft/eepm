#!/bin/sh

PKGNAME=master-pdf-editor
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Master PDF Editor from the official site"
URL="https://master-pdf-editor.ru/"

. $(dirname $0)/common.sh

PKG=''
# Strict supported list
case $(epm print info -e) in
    AstraLinuxCE/*|Debian/9|Ubuntu/18)
        PKG="master-pdf-editor-$VERSION-qt5.9.x86_64.deb"
        ;;
    AstraLinuxSE/1.7*|Debian/*|Ubuntu/*)
        PKG="master-pdf-editor-$VERSION-qt5.x86_64.deb"
        ;;
    RedOS/*|AlterOS/*|ALTLinux/*|CentOS/*|RockyLinux/*)
        PKG="master-pdf-editor-$VERSION-qt5.x86_64.rpm"
        ;;
esac

if [ -z "$PKG" ] ; then
    case $(epm print info -p) in
        rpm)
            PKG="master-pdf-editor-$VERSION-qt5.x86_64.rpm"
            ;;
        *)
            PKG="master-pdf-editor-$VERSION-qt5.x86_64.deb"
            ;;
    esac
fi

PKGURL=$(eget --list --latest https://code-industry.ru/get-master-pdf-editor-for-linux/ "$PKG") || fatal "Can't get package URL"

install_pkgurl

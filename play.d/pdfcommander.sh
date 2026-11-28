#!/bin/sh

PKGNAME=pdfcommander
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="PDF Commander (PDF viewer and editor) from the official site"
URL="https://pdf-editor.su/pdf-commander-dlya-linux.php"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] || [ "$RELEASE" = "*" ] ; then
    # https://pdf-editor.su/pdfcommander-3.0-11.x86_64.alt11.rpm
    if [ "$VERSION" = "*" ] ; then
        vmask='[0-9][0-9.]*'
    else
        vmask="$(echo "$VERSION" | sed -e 's|\.|\\.|g')"
    fi
    fullver="$(fetch_url "$URL" | grep -o "pdfcommander-$vmask-[0-9][0-9]*\.x86_64\.alt11\.rpm" | head -n1 | sed -e 's|^pdfcommander-\(.*\)\.x86_64\.alt11\.rpm$|\1|')"
    [ -n "$fullver" ] || fatal "Can't get version."
    VERSION="${fullver%-*}"
    RELEASE="${fullver##*-}"
fi

url="https://pdf-editor.su"

case "$(epm print info -e)" in
    ALTLinux/*)
        PKGURL="$url/pdfcommander-$VERSION-$RELEASE.x86_64.alt11.rpm"
        ;;
    RedOS/7*)
        PKGURL="$url/pdfcommander-$VERSION-$RELEASE.x86_64.red7.rpm"
        ;;
    RedOS/*)
        PKGURL="$url/pdfcommander-$VERSION-$RELEASE.x86_64.red8.rpm"
        ;;
    AstraLinuxSE/1.8*)
        PKGURL="$url/pdfcommander-$VERSION.$RELEASE.AstraSE1.8.deb"
        ;;
    *)
        case "$(epm print info -p)" in
            deb)
                PKGURL="$url/pdfcommander-$VERSION.$RELEASE.AstraOrel.deb"
                ;;
            *)
                PKGURL="$url/pdfcommander-$VERSION-$RELEASE.x86_64.rpm"
                ;;
        esac
        ;;
esac

install_pkgurl

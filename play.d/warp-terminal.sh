#!/bin/sh

PKGNAME=warp-terminal
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='The intelligent terminal from the official site'
URL="https://www.warp.dev/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
ARCHSUFF=""
[ "$arch" = "aarch64" ] && ARCHSUFF="_arm64"

case $(epm print info -p) in
    # force repack for all rpm based (due scripts)
    #rpm)
    #    PKGURL="https://app.warp.dev/download?package=rpm$ARCHSUFF"
    #    ;;
    *)
        PKGURL="https://app.warp.dev/download?package=deb$ARCHSUFF"
        ;;
esac

# get version from deb package
set_version()
{
    local URL="$1"
    # use temp dir
    PKGDIR="$(mktemp -d)"
    trap "rm -frv $PKGDIR" EXIT
    cd $PKGDIR || fatal
    eget -O pkg.deb "$URL"
    VERSION="$(epm print version of package pkg.deb)"
}

case "$(epm print info -d)" in
    ALTLinux)
        set_version $PKGURL || fatal "Can't get version"
        # due warp-terminal: /lib64/libcurl.so.4: version `CURL_OPENSSL_4' not found (required by warp-terminal)
        PKGURL="https://app.warp.dev/download?package=appimage$ARCHSUFF"
        # TODO: eget can't --get-real-url or --get-filename for the url
        install_pack_pkgurl $VERSION
        exit
        ;;
esac

install_pkgurl

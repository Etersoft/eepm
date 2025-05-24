#!/bin/sh

PKGNAME=YouTube-Music
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION="YouTube Music Desktop App bundled with custom plugins (and built-in ad blocker / downloader)"
URL="https://github.com/th-ch/youtube-music"

. $(dirname $0)/common.sh

# hack for YouTube-Music-3.6.2.AppImage. eget trying to download armv7l ver instead of x86_64
get_x86_64_ver(){
    if [ "$VERSION" = "*" ]; then
        VERSION=$(eget --list --latest "https://github.com/th-ch/youtube-music/releases" "YouTube-Music-*.AppImage" \
            | grep -oE 'YouTube-Music-[0-9]+\.[0-9]+(\.[0-9]+)?' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
        
        mask="YouTube-Music-$VERSION.AppImage" 
    else
        mask="YouTube-Music-$VERSION.AppImage" 
    fi
}

case $(epm print info -a) in
    x86_64)
        get_x86_64_ver ;;
    armv7l)
        mask="YouTube-Music-$VERSION-armv7l.AppImage" ;; 
    aarch64)
        mask="YouTube-Music-$VERSION-arm64.AppImage" ;;  
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)" ;;
esac

PKGURL="$(eget --list --latest https://github.com/th-ch/youtube-music/releases/ "$mask")"

install_pkgurl

#!/bin/sh

PKGNAME=lycheeslicer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Lychee Slicer - A powerful and versatile Slicer for Resin and Filament 3D Printers from the official site"
URL="https://mango3d.io/downloads/"

. $(dirname $0)/common.sh

# they have broken require on libicu56 (in embedded libQt5 from 2016)
case "$(epm print info -s)" in
    alt)
        epm installed libicu56 || epm play libicu56 || fatal
        ;;
esac

STDCPKG="libstdc++"
epm installed $STDCPKG || STDCPKG="libstdc++6"

if epm installed $STDCPKG ; then
    stdcver=$(epm print version for package "$STDCPKG" | head -n1)
    if [ -n "$stdcver" ] && [ "$(epm print compare version "$stdcver" "11.0")" = "-1" ] ; then
           # all next versions require libstdc++ >= 11 (libstdc++.so.6(GLIBCXX_3.4.29)(64bit))
           VERSION="4.1.0"
    fi
fi

PKGURL="$(eget --list --latest https://mango3d.io/downloads/ "LycheeSlicer-$VERSION.deb")"

# restore missed CDN for the latest release
PKGURL=$(echo $PKGURL | sed -e 's|mango-lychee.nyc3.digitaloceanspaces.com|mango-lychee.nyc3.cdn.digitaloceanspaces.com|')

if ! eget --check "$PKGURL" ; then
    # all previous versions return url to cdn with broken SSL (SSL connection broken only with wget or works only in a browser):
    # Connecting to mango-lychee.nyc3.cdn.digitaloceanspaces.com (mango-lychee.nyc3.cdn.digitaloceanspaces.com)|205.185.216.42|:443... connected.
    # Unable to establish SSL connection.
    if epm assure curl ; then
        export EGET_BACKEND=curl
    else
        PKGURL=$(echo $PKGURL | sed -e 's|mango-lychee.nyc3.cdn|mango-lychee.nyc3|')
    fi
fi

epm install $PKGURL

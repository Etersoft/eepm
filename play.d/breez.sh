#!/bin/sh

PKGNAME=breez
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Breez (Бриз) messenger client from the official site"
URL="https://disk.360.yandex.ru/d/3OcUkQVG_L_QXQ"

. $(dirname $0)/common.sh

# only the latest build is kept in the public folder (direct links are temporary)
warn_version_is_not_supported

# breez-client-26.1.9-linux-x86_64.rpm, breez-client-26.1.9-linux-amd64.deb
case "$(epm print info -p)" in
    deb)
        suffix='linux-amd64\.deb$'
        ;;
    *)
        suffix='linux-x86_64\.rpm$'
        ;;
esac

PUBLIC_KEY="https://disk.yandex.ru/d/3OcUkQVG_L_QXQ"
API="https://cloud-api.yandex.net/v1/disk/public/resources"
DIR="/Linux"

# list files in the Linux folder of the public Yandex Disk resource
file="$(fetch_url "$API?public_key=$PUBLIC_KEY&path=$DIR&limit=100" | tr '{}' ',,' | tr ',' '\n' | grep '"name":' | sed -e 's|.*"name": *"||' -e 's|".*||' | grep -E "^breez-client-[0-9.]+-$suffix" | sort -V | tail -n1)"
[ -n "$file" ] || fatal "Can't find Breez package in $URL$DIR"

# get a temporary direct download link
PKGURL="$(fetch_url "$API/download?public_key=$PUBLIC_KEY&path=$DIR/$file" | sed -e 's|.*"href" *: *"||' -e 's|".*||')"
[ -n "$PKGURL" ] || fatal "Can't get download URL for $file"

install_pkgurl

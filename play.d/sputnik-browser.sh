#!/bin/sh

PKGNAME=sputnik-browser-stable
SUPPORTEDARCHES="x86_64"
# discontinued
# https://bugzilla.altlinux.org/43495
#DESCRIPTION="Sputnik browser from the official site"

. $(dirname $0)/common.sh

URL="https://sputnik-lab.com/api-updates/updates/apps/meta?channel=b2c-distrs-on-site"

url_by_id_content()
{
    local id_content="$1"
    epm tool eget -q -O- "$URL" | grep -A6 "$id_content" | tail -n1 | sed -e 's|.*"url": "||' -e 's|".*||'
}

case "$(epm print info -e)" in
    Ubuntu/20.04)
        id_content='ubuntu20-id'
        ;;
    Ubuntu/16.04)
        id_content='ubuntu-id'
        ;;
    Ubuntu/*)
        id_content='ubuntu20-id'
        ;;
    ALTLinux/c8)
        id_content='alt-id'
        ;;
    ALTLinux/*|ALTServer/*)
        id_content='alt9-id'
        ;;
    AstraLinux*)
        id_content='astrase-id'
        ;;
    RedOS/*)
        id_content='redos-id'
        ;;
    RosaLinux/*)
        id_content='rosa-id'
        ;;
    Windows/*)
        id_content='win-id'
        ;;
    *)
        fatal "Unsupported system $(epm print info -e)"
        ;;
esac

epm install $(url_by_id_content "browser-b2c-$id_content")

ERR=$?
if [ "$ERR" = 0 ] ; then
    echo "Running # /opt/sputnik-browser/sputnik_client --generate_branding to get license in config.dat"
    a='' $SUDO /opt/sputnik-browser/sputnik_client --generate_branding
    echo "Disable strange system service sputnik_client"
    serv sputnik_client off
    $SUDO killall sputnik_client
fi

exit $ERR

#!/bin/sh

PKGNAME=sputnik-browser-stable
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Sputnik browser from the official site"

. $(dirname $0)/common.sh


url_by_id_content()
{
    local id_content="$1"
    epm tool eget -q -O- https://sputnik-lab.com/api-updates/updates/apps/meta?channel=b2c-distrs-on-site | grep -A6 "$id_content" | tail -n1 | sed -e 's|.*"url": "||' -e 's|".*||'
}

case "$($DISTRVENDOR -e)" in
    Ubuntu/20.04)
        id_content='browser-b2c-ubuntu20-id'
        ;;
    Ubuntu/16.04)
        id_content='browser-b2c-ubuntu-id'
        ;;
    Ubuntu/*)
        id_content='browser-b2c-ubuntu20-id'
        ;;
    ALTLinux/c8)
        id_content='browser-b2c-alt-id'
        ;;
    ALTLinux/*|ALTServer/*)
        id_content='browser-b2c-alt9-id'
        ;;
    AstraLinux/orel)
        id_content='browser-b2c-astrase-id'
        ;;
    AstraLinux/*)
        id_content='browser-b2c-astrace-id'
        ;;
    RedOS/*)
        id_content='browser-b2c-redos-id'
        ;;
    RosaLinux/*)
        id_content='browser-b2c-rosa-id'
        ;;
    Windows/*)
        id_content='browser-b2c-win-id'
        ;;
    *)
        fatal "Unsupported system $($DISTRVENDOR -e)"
        ;;
esac

epm install $(url_by_id_content $id_content)

ERR=$?
if [ "$ERR" = 0 ] ; then
    echo "Running # /opt/sputnik-browser/sputnik_client --generate_branding to get license in config.dat"
    a='' $SUDO /opt/sputnik-browser/sputnik_client --generate_branding
fi

exit $ERR

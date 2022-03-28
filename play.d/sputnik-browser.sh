#!/bin/sh

PKGNAME=sputnik-browser-stable
DESCRIPTION="Sputnik browser from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported by vendor" && exit 1


case "$($DISTRVENDOR -e)" in
    Ubuntu/20.04)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/f02e89f4-a256-4a8f-964e-047e3a44eaff/sputnik-browser-stable_5.6.6306.0-1_amd64.deb
        ;;
    Ubuntu/16.04)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/a5be3569-9c9b-4d91-ae7e-a44c7e96e907/sputnik-browser-stable_5.6.6312.0-1_amd64.deb
        ;;
    Ubuntu/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/f02e89f4-a256-4a8f-964e-047e3a44eaff/sputnik-browser-stable_5.6.6306.0-1_amd64.deb
        ;;
    ALTLinux/c8)
        epm --repack install https://upd.sputnik-lab.com/api-updates/updates/download/94d70495-75ec-4ad7-831d-8008d0525d90/sputnik-browser-stable-5.6.6322.0-1.x86_64.rpm
        ;;
    ALTLinux/*|ALTServer/*)
        epm --repack install https://upd.sputnik-lab.com/api-updates/updates/download/49734e35-cfe1-493c-bfae-8fa83f2a4365/sputnik-browser-stable-5.6.6324.0-1.x86_64.rpm
        ;;
    AstraLinux/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/3fb587b6-19fa-421b-b757-7f232ed46d74/sputnik-browser-stable_5.6.6316.0-1_amd64.deb
        ;;
    RedOS/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/569b5726-5899-4bb1-b064-6b1b00a5bc15/sputnik-browser-stable-5.6.6325.0-1.x86_64.rpm
        ;;
    RosaLinux/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/0618f239-abfb-44f8-a771-1622a6336eb6/sputnik-browser-stable-5.6.6319.0-1.x86_64.rpm
        ;;
    Windows/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/c8b0945b-4d89-4a72-82ec-b7ed1b259384/SputnikOfflineInstaller-free-5.6.6282.0.exe
        ;;
esac

ERR=$?
if [ "$ERR" = 0 ] ; then
    echo "Running # /opt/sputnik-browser/sputnik_client --generate_branding to get license in config.dat"
    a='' $SUDO /opt/sputnik-browser/sputnik_client --generate_branding
fi

exit $ERR

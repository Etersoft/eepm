#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=sputnik-browser-stable

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Sputnik browser from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported by vendor" && exit 1


case "$($DISTRVENDOR -e)" in
    Ubuntu/20.04)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/e91f9650-23cf-411c-9f51-f723acca5ced/sputnik-browser-stable_5.5.6078.0-1_amd64.deb || exit
        ;;
    Ubuntu/16.04)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/f133a2c4-0d2e-4e40-989b-5b86d9b246e5/sputnik-browser-stable_5.5.6145.0-1_amd64.deb || exit
        ;;
    Ubuntu/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/e91f9650-23cf-411c-9f51-f723acca5ced/sputnik-browser-stable_5.5.6078.0-1_amd64.deb || exit
        ;;
    ALTLinux/c8)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/6b338f94-64cc-4530-9515-0c2b1bda36ee/sputnik-browser-stable-5.5.6150.0-1.x86_64.rpm || exit
        ;;
    ALTLinux/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/8e611d44-be64-4397-8ce4-a4af5616c65e/sputnik-browser-stable-5.5.6108.0-1.x86_64.rpm || exit
        ;;
    AstraLinux/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/ebd059bb-98ab-4851-8c7b-1d6bada095b6/sputnik-browser-stable_5.5.6154.0-1_amd64.deb || exit
        ;;
    RedOS/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/7f5d5ad0-a5f9-4ccd-ad4a-6e4a1be777de/sputnik-browser-stable-5.5.6101.0-1.x86_64.rpm || exit
        ;;
    RosaLinux/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/b4a5bacd-31aa-4e6f-bffa-8fc53b35a51a/sputnik-browser-stable-5.5.6115.0-1.x86_64.rpm || exit
        ;;
    Windows/*)
        epm install https://upd.sputnik-lab.com/api-updates/updates/download/21425e74-e3fb-42bc-95cd-e3c243db75b5/SputnikOfflineInstaller-b2c-5.4.5991.1.exe || exit
        ;;
esac

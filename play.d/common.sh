#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

get_latest_version()
{
    local URL="https://eepm.ru/app-versions"
    epm tool eget -q -O- "$URL/$1"
}

case "$1" in
    "--remove")
        epm remove $PKGNAME
        exit
        ;;
    "--package")
        echo "$PKGNAME"
        exit
        ;;
    "--installed")
        epm installed $PKGNAME
        exit
        ;;
    "--installed-version")
        epm print version for package $PKGNAME
        exit
        ;;
    "--description")
        echo "$DESCRIPTION"
        exit
        ;;
    "--update")
        if ! epm installed $PKGNAME ; then
            echo "Skipping update of $PKGNAME (package is not installed)"
            exit
        fi
        pkgver="$(epm print version for package $PKGNAME)"
        if [ -n "$pkgver" ] && [ "$(get_latest_version $PKGNAME)" = "$pkgver" ] ; then
            echo "There is no newer version of $PKGNAME then installed version $version."
            exit
        fi
        ;;
    "--run")
        # just pass
        ;;
    *)
        fatal "Unknown command $1"
        ;;
esac


check_supported_arch()
{
    # skip checking if no arches
    [ -n "$1" ] || return 0
    for i in $* ; do
        [ "$(epm print info -a)" = "$i" ] && return 0
    done

    return 1
}

check_supported_arch $SUPPORTEDARCHES || fatal "Only $SUPPORTEDARCHES is supported"

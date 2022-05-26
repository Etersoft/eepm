#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
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
    "--description")
        echo "$DESCRIPTION"
        exit
        ;;
    "--update")
        if ! epm installed $PKGNAME ; then
            echo "Skipping update of $PKGNAME (package is not installed)"
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


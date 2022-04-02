#!/bin/sh

[ "$1" != "--run" ] && echo "Remove all 32 bit packages from 64 bit system" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

case "$($DISTRVENDOR -s)" in
    alt)
        epm --verbose --simulate remove $(epmqp "^i586-")
        ;;
    ubuntu|debian)
        epm --verbose --simulate remove $(epmqp "^i386-")
        ;;
    *)
        fatal "unsupported vendor $($DISTRVENDOR -s)"
        ;;
esac

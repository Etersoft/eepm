#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# pantum-r_1.0.17-1astra1_amd64.deb_.zip
case "$TAR" in
    */pantum-r_*_amd64.deb_.zip|pantum-r_*_amd64.deb_.zip)
        erc --here "$TAR" || fatal
        return_tar pantum-r_*_amd64.deb
        ;;
    *)
        fatal "We support only pantum-r_*_amd64.deb_.zip"
        ;;
esac

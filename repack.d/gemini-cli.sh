#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
    deb)
        add_directrequires nodejs
        ;;
    *)
        add_directrequires '/usr/bin/node'
        ;;
esac

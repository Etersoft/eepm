#!/bin/sh

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-python.sh

fix_python_path

if [ "$(epm print info -s)" = "fedora" ] ; then
    # Import names do not match package names on Fedora.
    filter_from_python_requires '^python3-(libarchive|pil|websocket)$'
    add_directrequires python3-libarchive-c python3-pillow python3-websocket-client
fi
add_python_requires

add_directrequires jq
add_unirequires libSDL3.so.0

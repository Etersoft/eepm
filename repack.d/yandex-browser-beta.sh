#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

[ -x $BUILDROOT/usr/bin/yandex-browser ] || ln -sv yandex-browser-beta $BUILDROOT/usr/bin/yandex-browser

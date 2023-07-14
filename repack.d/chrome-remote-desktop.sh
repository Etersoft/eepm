#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=chrome-remote-desktop

# install all requires packages before packing ($ rpmreqs chrome-remote-desktop  | xargs echo)
PREINSTALL_PACKAGES="coreutils glib2 libcairo libdbus libdrm libexpat libgbm libgio libgtk+3 libnspr libnss libpango libX11 libxcb libXdamage libXext libXfixes libXrandr libXtst libutempter \
     python3-base python3-module-psutil python3 rpm-build-python3"

. $(dirname $0)/common-chromium-browser.sh

cleanup

subst '1iBuildRequires:rpm-build-python3' $SPEC

set_autoreq 'yes'

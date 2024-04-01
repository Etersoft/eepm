#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

fix_chrome_sandbox $PRODUCTDIR/cef/chrome-sandbox

fix_desktop_file /usr/bin/zoom

# https://bugzilla.altlinux.org/47427
remove_file /opt/zoom/Qt/qml/Qt/labs/lottieqt/liblottieqtplugin.so

add_libs_requires

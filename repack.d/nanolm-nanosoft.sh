#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# from upstream postinstall script: system user and its home dir
cat <<EOF | create_file /usr/lib/sysusers.d/nanolm-nanosoft.conf
u nanolm-nanosoft - "NanoSoft License Manager Server" "/var/lib/Nanosoft/License Server" /usr/sbin/nologin
EOF

cat <<EOF | create_file /usr/lib/tmpfiles.d/nanolm-nanosoft.conf
d "/var/lib/Nanosoft/License Server" 0755 nanolm-nanosoft nanolm-nanosoft -
EOF

# nanoLMctl-Nanosoft-admin.sh runs nanoLMctl-Nanosoft via pkexec
add_requires /usr/bin/pkexec

add_unirequires libQt5Core.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5Widgets.so.5 libQt5Xml.so.5

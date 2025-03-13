#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sunshine

. $(dirname $0)/common.sh

# Sunshine needs access to uinput to create mouse and gamepad events.
cat <<EOF | create_file /usr/lib/udev/rules.d/60-sunshine.rules
KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess
EOF

# Autostart service
cat <<EOF | create_file /usr/lib/systemd/user/sunshine.service
[Unit]
Description=Self-hosted game stream host for Moonlight
StartLimitIntervalSec=500
StartLimitBurst=5
PartOf=graphical-session.target
Wants=xdg-desktop-autostart.target
After=xdg-desktop-autostart.target

[Service]
ExecStart=/usr/bin/sunshine
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=xdg-desktop-autostart.target
EOF

epm assure patchelf
epm assure ldd glibc-utils

BOOST_REPO_VERSION=$(LC_ALL=C epm info boost | grep -oP '^Version\s*:\s*\K[^\s]+' | sed 's/^[0-9]*://g' | cut -d '-' -f 1)
BOOST_FEDORA_VERSION=$(a='' ldd usr/bin/sunshine | grep -oP 'libboost_[^ ]+\.so\.\K[0-9]+\.[0-9]+\.[0-9]+' | sort -u)
BOOST_LIBS=$(a='' ldd usr/bin/sunshine | grep -oP 'libboost_[^ ]+\.so' | sort -u | sed 's/libboost_//; s/\.so//')

MINIUPNPC_FEDORA_VERSION=$(a='' ldd usr/bin/sunshine | grep -oP 'libminiupnpc\.so\.\K[0-9]+')
MINIUPNPC_REPO_VERSION=$(LC_ALL=C epm search miniupnpc |  grep -Eo 'libminiupnpc[0-9]+' | grep -Eo '[0-9]+' | sort -V | tail -n1)

if [ -z $MINIUPNPC_REPO_VERSION ] ; then
    MINIUPNPC_REPO_VERSION=$(LC_ALL=C epm ql miniupnpc | grep -o 'libminiupnpc\.so\.[0-9]\+' | sed 's/.*\.so\.//' | sort -V | tail -n1)
fi

# Replace fedora libboost to system libboost
for lib in ${BOOST_LIBS}; do
    a='' patchelf --replace-needed "libboost_${lib}.so.${BOOST_FEDORA_VERSION}" "libboost_${lib}.so.${BOOST_REPO_VERSION}" "usr/bin/sunshine"
done

# Replace fedora libminiupnpc to system libminiupnpc
a='' patchelf --replace-needed "libminiupnpc.so.$MINIUPNPC_FEDORA_VERSION" "libminiupnpc.so.$MINIUPNPC_REPO_VERSION"  "usr/bin/sunshine"

a='' patchelf --replace-needed "libappindicator3.so.1" "libayatana-appindicator3.so.1" "usr/bin/sunshine"

add_libs_requires

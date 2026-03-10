#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

erc --here $TAR || fatal

install -Dm755 xray usr/bin/xray

mkdir -p usr/share/xray
for i in geoip.dat geosite.dat ; do
    [ -f "$i" ] && mv "$i" usr/share/xray/
done

mkdir -p etc/xray

cat <<EOF | create_file /etc/xray/config.json
{
}
EOF

cat <<EOF | create_file /usr/lib/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://xtls.github.io
After=network.target nss-lookup.target

[Service]
#User=xray
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/xray run -confdir /etc/xray/
Restart=on-abort
RestartPreventExitStatus=23
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | create_file /usr/lib/systemd/system/xray@.service
[Unit]
Description=Xray Service (%i)
Documentation=https://xtls.github.io
After=network.target nss-lookup.target

[Service]
#User=xray
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/xray run -config /etc/xray/%i.json
Restart=on-abort
RestartPreventExitStatus=23
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

erc pack $PKGNAME.tar usr etc

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking
license: MPL-2.0
url: https://github.com/XTLS/Xray-core
summary: Xray, Pair the Future
description: A platform for building proxies to bypass network restrictions.
EOF

return_tar $PKGNAME.tar

#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -E 's/^[^.]+\.[^.]+\.(.+)\.linux.*/\1/')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

# Create launcher script
cat <<'EOF' | create_file usr/bin/$PRODUCT
#!/bin/sh
exec /opt/prowlarr/Prowlarr -nobrowser "$@"
EOF
chmod 755 usr/bin/$PRODUCT

# Create systemd service
cat <<EOF | create_file usr/lib/systemd/system/$PRODUCT.service
[Unit]
Description=Prowlarr Daemon
After=syslog.target network.target

[Service]
User=$PRODUCT
Group=$PRODUCT
Type=simple
ExecStart=/opt/$PRODUCT/Prowlarr -nobrowser -data=/var/lib/$PRODUCT/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create sysusers.d config for user creation
cat <<EOF | create_file usr/lib/sysusers.d/$PRODUCT.conf
u $PRODUCT - "Prowlarr service" /var/lib/$PRODUCT
EOF

# Create tmpfiles.d config for directories
cat <<EOF | create_file usr/lib/tmpfiles.d/$PRODUCT.conf
d /var/lib/$PRODUCT 0750 $PRODUCT $PRODUCT -
EOF

erc pack $PKGNAME.tar opt usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: GPLv3
url: https://prowlarr.com/
summary: Indexer manager for Sonarr, Radarr and Lidarr
description: Prowlarr is an indexer manager/proxy for PVR apps like Sonarr, Radarr and Lidarr.
requires: curl sqlite3
EOF

return_tar $PKGNAME.tar

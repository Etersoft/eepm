#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

# Create launcher script
cat <<'EOF' | create_file usr/bin/$PRODUCT
#!/bin/sh
exec /usr/bin/python3 /opt/bazarr/bazarr.py "$@"
EOF
chmod 755 usr/bin/$PRODUCT

# Create systemd service
cat <<EOF | create_file usr/lib/systemd/system/$PRODUCT.service
[Unit]
Description=Bazarr Daemon
After=syslog.target network.target

[Service]
User=$PRODUCT
Group=$PRODUCT
Type=simple
WorkingDirectory=/opt/$PRODUCT
ExecStart=/usr/bin/python3 /opt/$PRODUCT/bazarr.py
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create sysusers.d config for user creation
cat <<EOF | create_file usr/lib/sysusers.d/$PRODUCT.conf
u $PRODUCT - "Bazarr service" /var/lib/$PRODUCT
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
url: https://www.bazarr.media/
summary: Subtitle manager for Sonarr and Radarr
description: Bazarr is a companion application to Sonarr and Radarr that manages and downloads subtitles.
requires: python3
EOF

return_tar $PKGNAME.tar

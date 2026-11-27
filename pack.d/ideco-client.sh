#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# IdecoClient-install.sh is a self-extracting bash script: gzipped tar after the RAWDATA: line
# readonly version=23.0.1093.0
[ -n "$VERSION" ] && [ "$VERSION" != "*" ] || VERSION="$(grep -a -m1 '^readonly version=' "$TAR" | sed -e 's|^readonly version=||' -e 's|[[:space:]].*||')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION
PRODUCTDIR=/opt/$PRODUCT

mkdir -p opt/$PRODUCT || fatal
sed '0,/^RAWDATA:$/d' "$TAR" | tar --no-same-owner -zx -C opt/$PRODUCT || fatal

# used only for the vendor's installation to /usr/local
rm -f opt/$PRODUCT/uninstall.sh

# The application is self-contained (bundled glibc) and runs via the bundled ld.so (as the vendor's installer does)
for i in IdecoClient IdecoService ; do
    cat <<EOF | create_file $PRODUCTDIR/$i.sh
#!/bin/sh
exec $PRODUCTDIR/ld.so --argv0 $i --library-path $PRODUCTDIR/lib $PRODUCTDIR/$i "\$@"
EOF
    chmod 755 opt/$PRODUCT/$i.sh
done

mkdir -p usr/bin
ln -s $PRODUCTDIR/IdecoClient.sh usr/bin/$PRODUCT

cat <<EOF | create_file /usr/lib/systemd/system/IdecoService.service
[Unit]
Description=IdecoService
After=network.target

[Service]
ExecStart=$PRODUCTDIR/IdecoService.sh
Type=notify
Restart=always
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
StartupWMClass=Agent
Type=Application
Name=Ideco Client
Exec=$PRODUCT --show
Icon=$PRODUCT
Comment=Ideco NGFW client (VPN, ZTNA)
StartupNotify=true
Terminal=false
Categories=Network;
Keywords=Agent;VPN;vpn;ztna;client;ideco;Ideco
EOF

install_file opt/$PRODUCT/res/client_logo.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: Proprietary
url: https://ideco.ru/
summary: Ideco Client for Ideco NGFW
description: Ideco Client (Ideco Agent) provides VPN and ZTNA access via Ideco NGFW.
EOF

return_tar $PKGNAME.tar

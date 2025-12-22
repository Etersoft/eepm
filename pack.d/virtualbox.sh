#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# VirtualBox-7.2.4-170995-Linux_amd64.run
BASENAME=$(basename "$TAR" .run)
VERSION=$(echo "$BASENAME" | sed -e 's|VirtualBox-||' -e 's|-Linux_amd64||')
# 7.2.4-170995 -> 7.2.4
VERSION=$(echo "$VERSION" | sed -e 's|-[0-9]*$||')

PKGNAME=$PRODUCT-$VERSION

# Extract .run without executing
chmod +x "$TAR"
"$TAR" --noexec --nox11 --target vbox-installer || fatal "Can't extract VirtualBox installer"

cd vbox-installer || fatal "Can't enter vbox-installer"

# Extract the main archive
erc VirtualBox.tar.bz2 || fatal "Can't extract VirtualBox.tar.bz2"

cd .. || fatal

PRODUCTDIR=opt/VirtualBox
mkdir -p $PRODUCTDIR
mv vbox-installer/* $PRODUCTDIR/

# Remove installer leftovers
rm -f $PRODUCTDIR/VirtualBox.tar.bz2
rm -f $PRODUCTDIR/*.sh
rm -f $PRODUCTDIR/LICENSE
rm -rf vbox-installer

# Set SUID on required executables
for exe in VirtualBoxVM VBoxHeadless VBoxNetAdpCtl VBoxNetDHCP VBoxNetNAT VBoxVolInfo ; do
    [ -f "$PRODUCTDIR/$exe" ] && chmod 4755 "$PRODUCTDIR/$exe"
done

# Create /usr/bin symlinks via VBox.sh wrapper
mkdir -p usr/bin
for cmd in VirtualBox VirtualBoxVM VBoxManage VBoxSDL VBoxHeadless VBoxAutostart VBoxBalloonCtrl VBoxBugReport VBoxDTrace VBoxVRDP ; do
    [ -f "$PRODUCTDIR/$cmd" ] || [ -L "$PRODUCTDIR/$cmd" ] && ln -s /opt/VirtualBox/VBox.sh "usr/bin/$cmd"
done

# Install desktop file
mkdir -p usr/share/applications
cp $PRODUCTDIR/virtualbox.desktop usr/share/applications/ 2>/dev/null || true

# Install icons
for size in 16 32 48 64 128 ; do
    mkdir -p "usr/share/icons/hicolor/${size}x${size}/apps"
    cp "$PRODUCTDIR/icons/${size}x${size}/virtualbox.png" "usr/share/icons/hicolor/${size}x${size}/apps/" 2>/dev/null || true
done

# Install MIME types
mkdir -p usr/share/mime/packages
cp $PRODUCTDIR/virtualbox.xml usr/share/mime/packages/ 2>/dev/null || true

# Install udev rules
mkdir -p usr/lib/udev/rules.d
cp $PRODUCTDIR/60-vboxdrv.rules usr/lib/udev/rules.d/ 2>/dev/null || true

# Install modprobe config
mkdir -p usr/lib/modprobe.d
echo "install vboxdrv /sbin/modprobe --ignore-install vboxdrv && /sbin/modprobe vboxnetflt && /sbin/modprobe vboxnetadp" > usr/lib/modprobe.d/virtualbox.conf

# Create sysusers.d for vboxusers group
mkdir -p usr/lib/sysusers.d
echo "g vboxusers - -" > usr/lib/sysusers.d/virtualbox.conf

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PRODUCT.eepm.yaml
name: $PRODUCT
group: Emulators
license: GPL-2.0-only AND GPL-3.0-only AND CDDL-1.0
url: https://www.virtualbox.org
summary: VirtualBox - powerful x86 and AMD64/Intel64 virtualization
description: Oracle VM VirtualBox is a powerful cross-platform virtualization product for enterprise and home use.
EOF

return_tar $PKGNAME.tar

#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# tar.gz contains a single .run ELF installer
erc --here unpack "$TAR" || fatal
RUNFILE="$(echo FreeFileSync_*_Install.run)"
[ -f "$RUNFILE" ] || fatal "Installer .run file not found"
chmod +x "$RUNFILE"

[ -n "$VERSION" ] || VERSION="$(echo "$RUNFILE" | grep -oE '[0-9]+\.[0-9]+')"
[ -n "$VERSION" ] || fatal "Can't get package version"

# extract using the bundled installer (requires a terminal)
mkdir -p opt/$PRODUCT
script -qc "./$RUNFILE --directory $(pwd)/opt/$PRODUCT --accept-license --skip-overview" /dev/null || fatal "Installer failed"

# create wrapper scripts
mkdir -p usr/bin
cat <<'EOFBIN' > usr/bin/freefilesync
#!/bin/sh
exec /opt/freefilesync/FreeFileSync "$@"
EOFBIN
chmod 755 usr/bin/freefilesync

cat <<'EOFBIN' > usr/bin/realtimesync
#!/bin/sh
exec /opt/freefilesync/RealTimeSync "$@"
EOFBIN
chmod 755 usr/bin/realtimesync

# desktop files
mkdir -p usr/share/applications
cat <<'EOF' > usr/share/applications/FreeFileSync.desktop
[Desktop Entry]
Type=Application
Name=FreeFileSync
GenericName=Folder Comparison and Synchronization
Exec=freefilesync %F
Icon=freefilesync
Terminal=false
Categories=Utility;FileTools;
StartupNotify=true
MimeType=application/x-freefilesync-gui;application/x-freefilesync-batch;
Comment=Folder Comparison and Synchronization
EOF

cat <<'EOF' > usr/share/applications/RealTimeSync.desktop
[Desktop Entry]
Type=Application
Name=RealTimeSync
GenericName=Automated Synchronization
Exec=realtimesync %F
Icon=realtimesync
Terminal=false
Categories=Utility;FileTools;
StartupNotify=true
MimeType=application/x-freefilesync-real;
Comment=Automated Synchronization
EOF

# icons
mkdir -p usr/share/icons/hicolor/128x128/apps
cp opt/$PRODUCT/Resources/FreeFileSync.png usr/share/icons/hicolor/128x128/apps/freefilesync.png
cp opt/$PRODUCT/Resources/RealTimeSync.png usr/share/icons/hicolor/128x128/apps/realtimesync.png

# mime types
mkdir -p usr/share/mime/packages
cp opt/$PRODUCT/Resources/freefilesync-mime.xml usr/share/mime/packages/ 2>/dev/null ||
cat <<'EOF' > usr/share/mime/packages/freefilesync-mime.xml
<?xml version="1.0"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-freefilesync-gui">
    <glob pattern="*.ffs_gui"/>
    <comment>FreeFileSync Configuration</comment>
  </mime-type>
  <mime-type type="application/x-freefilesync-batch">
    <glob pattern="*.ffs_batch"/>
    <comment>FreeFileSync Batch File</comment>
  </mime-type>
  <mime-type type="application/x-freefilesync-real">
    <glob pattern="*.ffs_real"/>
    <comment>RealTimeSync Configuration</comment>
  </mime-type>
</mime-info>
EOF

# remove installer artifacts not needed in package
rm -f opt/$PRODUCT/uninstall.sh

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: File tools
license: GPL-3.0
url: https://freefilesync.org
summary: Folder comparison and synchronization
description: FreeFileSync is a folder comparison and synchronization software that creates and manages backup copies of all your important files.
EOF

return_tar $PKGNAME.tar

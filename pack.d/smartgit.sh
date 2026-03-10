#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc --here unpack "$TAR" || fatal
cd smartgit || fatal

# Get version from version file or directory name
VERSION=$(cat lib/smartgit-version.txt 2>/dev/null || basename "$TAR" | grep -oP 'smartgit-\K[0-9_]+')
VERSION=$(echo "$VERSION" | sed 's/_/./g')
[ -n "$VERSION" ] || VERSION="1.0"

PKGNAME=$PRODUCT-$VERSION

cd ..
mkdir -p opt
mv smartgit opt/$PRODUCT

mkdir -p usr/bin
ln -s /opt/$PRODUCT/bin/smartgit.sh usr/bin/$PRODUCT

# Install icons
for size in 32 48 64 128 256 ; do
    icon="opt/$PRODUCT/bin/smartgit-$size.png"
    if [ -f "$icon" ] ; then
        mkdir -p usr/share/icons/hicolor/${size}x${size}/apps
        cp "$icon" usr/share/icons/hicolor/${size}x${size}/apps/$PRODUCT.png
    fi
done

mkdir -p usr/share/applications
cat > usr/share/applications/$PRODUCT.desktop <<EOF
[Desktop Entry]
Name=SmartGit
Comment=Git GUI client
Exec=$PRODUCT
Icon=$PRODUCT
Terminal=false
Type=Application
Categories=Development;RevisionControl;
EOF

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Other
license: Proprietary
url: https://www.syntevo.com/smartgit/
summary: SmartGit - Git GUI client
description: SmartGit is a graphical Git client with support for GitHub, GitLab, and Bitbucket.
EOF

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar

#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
PRODUCT=unreal-engine

. $(dirname $0)/common.sh
# Linux_Unreal_Engine_5.6.1.zip
BASENAME=$(basename $TAR .zip)
VERSION=$(echo $BASENAME | sed -e 's|Linux_Unreal_Engine_||' )

mkdir -p opt
erc $TAR || fatal

mv -v $BASENAME opt/unreal-engine || fatal

# Application & MIME icons
#for res in 16 24 32 48 64 256; do
for res in 256; do
    mkdir -p usr/share/icons/hicolor/${res}x${res}/mimetypes/
    install_file "ipfs://QmdrhQDe3BhyYvxKZpoLwXXAPHqwgm4qrrZ5xM83gN1v5n?filename=256.png" /usr/share/icons/hicolor/${res}x${res}/apps/unreal-engine.png || \
        install_file "https://aur.archlinux.org/cgit/aur.git/plain/256.png?h=unreal-engine-bin" /usr/share/icons/hicolor/${res}x${res}/apps/unreal-engine.png
    ln -s ../apps/unreal-engine.png usr/share/icons/hicolor/${res}x${res}/mimetypes/application-x-uproject.png
done

install_file "ipfs://QmNnvL93ax27uhApdYqDqpe4xcXgU2dCwFq7Sf8zq7obSi?filename=unreal-engine.desktop" /usr/share/applications/unreal-engine.desktop || \
    install_file "https://aur.archlinux.org/cgit/aur.git/plain/unreal-engine.desktop?h=unreal-engine-bin" /usr/share/applications/unreal-engine.desktop
install_file "ipfs://QmQYxgQgq4kcipXzBwR7Xq1W25gf8tWtDsocdptJHzGrHS?filename=unreal-engine.xml" /usr/share/mime/packages/unreal-engine.xml || \
    install_file "https://aur.archlinux.org/cgit/aur.git/plain/unreal-engine.xml?h=unreal-engine-bin" /usr/share/mime/packages/unreal-engine.xml

PKGNAME=$PRODUCT-$VERSION

# use tar.gz to save space
erc pack $PKGNAME.tar.gz opt usr || fatal
# remove unneed files right here
rm -rf opt usr

return_tar $PKGNAME.tar.gz


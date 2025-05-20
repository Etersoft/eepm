#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

VERSION=$(echo "$URL" | sed -nE 's#.*/v([0-9]+\.[0-9]+\.[0-9]+)/.*#\1#p')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/ventoy
mkdir -p usr/bin
mkdir -p usr/share/pixmaps
erc $TAR || fatal

cat <<EOF > usr/bin/ventoy-extend-persistent
#!/bin/sh
exec /opt/ventoy/ExtendPersistentImg.sh "\$@"
EOF

cat <<EOF > usr/bin/ventoygui
#!/bin/sh
cd /opt/ventoy || exit 1

for bin in ./VentoyGUI.*; do
  if [ -x "\$bin" ]; then
    exec "\$bin" "\$@"
  fi
done

echo "No suitable VentoyGUI binary found in /opt/ventoy."
exit 1
EOF

cat <<EOF > usr/bin/ventoyplugson
#!/bin/sh
cd /opt/ventoy || exit 1
exec ./VentoyPlugson.sh "\$@"
EOF

cat <<EOF > usr/bin/ventoy-persistent
#!/bin/sh
exec /opt/ventoy/CreatePersistentImg.sh "\$@"
EOF

cat <<EOF > usr/bin/ventoyweb
#!/bin/sh
cd /opt/ventoy || exit 1
exec ./VentoyWeb.sh "\$@"
EOF

cat <<EOF > usr/bin/ventoy
#!/bin/sh
cd /opt/ventoy || exit 1
exec ./Ventoy2Disk.sh "\$@"
EOF

chmod 755 usr/bin/ventoy-extend-persistent
chmod 755 usr/bin/ventoygui
chmod 755 usr/bin/ventoyplugson
chmod 755 usr/bin/ventoy-persistent
chmod 755 usr/bin/ventoyweb
chmod 755 usr/bin/ventoy

epm assure /usr/bin/xzcat

CURDIR=$(pwd)

ARCH=$(uname -m)

# Clean binaries
case "$ARCH" in
  x86_64)
    rm -v ventoy-$VERSION/VentoyGUI.aarch64
    rm -v ventoy-$VERSION/VentoyGUI.i386
    rm -v ventoy-$VERSION/VentoyGUI.mips64el
    rm -rv ventoy-$VERSION/tool/mips64el
    rm -rv ventoy-$VERSION/tool/i386
    rm -rv ventoy-$VERSION/tool/aarch64
    ;;
  aarch64)
    rm -v ventoy-$VERSION/VentoyGUI.x86_64
    rm -v ventoy-$VERSION/VentoyGUI.i386
    rm -v ventoy-$VERSION/VentoyGUI.mips64el
    rm -rv ventoy-$VERSION/tool/mips64el
    rm -rv ventoy-$VERSION/tool/i386
    rm -rv ventoy-$VERSION/tool/x86_64
    ;;
esac

cd "ventoy-$VERSION/tool/$ARCH" || exit 1

for file in *.xz; do
  outfile=$(echo "$file" | sed 's/\.xz$//')
  xzcat "$file" > "$outfile"
  chmod +x "$outfile"
done

rm -fv ./*.xz

# Clean up unused binaries
# Preserving mkexfatfs and mount.exfat-fuse because exfatprogs is incompatible
for binary in xzcat hexdump; do
    rm -fv $binary
done

# Link system binaries
for binary in xzcat hexdump; do
    ln -svf /usr/bin/$binary .
done

rm -v Ventoy2Disk.gtk2

cd "$CURDIR" || exit 1

sed -i 's|log\.txt|/var/log/ventoy.log|g' ventoy-$VERSION/WebUI/static/js/languages.js ventoy-$VERSION/tool/languages.json

mv -v ventoy-$VERSION/WebUI/static/img/VentoyLogo.png usr/share/pixmaps/ventoy.png

mv ventoy-$VERSION/* opt/$PRODUCT

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar

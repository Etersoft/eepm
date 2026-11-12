#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar
PRODUCTDIR=opt/eepm-wine/$PRODUCT

erc -C "$PRODUCTDIR" unpack "$TAR" || fatal
[ -s "$PRODUCTDIR/ceno.exe" ] || fatal "Can't find ceno.exe in the portable installer"

# NSIS installer plugins are not needed to run the extracted browser.
rm -rf "$PRODUCTDIR/\$PLUGINSDIR"

cat <<EOF >"$PRODUCTDIR/run.sh"
#!/bin/sh
export WINEPREFIX="\${WINEPREFIX:-\${XDG_DATA_HOME:-\$HOME/.local/share}/eepm-wine/$PRODUCT}"
export WINEDLLOVERRIDES="winemenubuilder.exe=d\${WINEDLLOVERRIDES:+;\$WINEDLLOVERRIDES}"
PROFILE="\${XDG_DATA_HOME:-\$HOME/.local/share}/$PRODUCT/profile"
mkdir -p "\$WINEPREFIX" "\$PROFILE" || exit 1
PROFILE="\$(winepath -w "\$PROFILE")" || exit 1
exec wine "/$PRODUCTDIR/ceno.exe" -profile "\$PROFILE" "\$@"
EOF
chmod 755 "$PRODUCTDIR/run.sh"

erc pack "$PKGNAME" opt/eepm-wine || fatal

return_tar "$PKGNAME"
